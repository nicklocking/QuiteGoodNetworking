import Foundation

@objc class ReceiveMessagesResponseProcessor: CoreDataResponseProcessor {
    
    let events: [WMessagingSocketEvent]
    let duringReplay: Bool
    let visibleGroupToken: String?
    
    /// visibleGroupToken is the group token of the conversation currently being read (if any)
    @objc required init(events:[WMessagingSocketEvent], duringReplay:Bool, visibleGroupToken: String?) {
        self.events = events
        self.duringReplay = duringReplay
        self.visibleGroupToken = visibleGroupToken
        
        super.init()
    }
    
    @available(*, deprecated: 1.0, message: "init not implemented; causes fatalError")
    required init() {
        fatalError("Not implemented")
    }
    
    override func processWithLocalContext(_ localContext: NSManagedObjectContext) {
        super.processWithLocalContext(localContext)
        
        var deliveredMIDs = [String]()
        var readMIDs = [String]()
        
        /// Group tokens for conversations which had not been fetched by the time that one of its messages was being processed
        var unfetchedGroupTokens = Set<String>()
        
        for event in events {
            
            guard let groupToken = event.groupToken else {
                assertionFailure("Received messages should always have a group token")
                continue
            }
            
            let conversation:Conversation
            if let existingConversation = Conversation.mr_findFirst(byAttribute: "groupToken", withValue: groupToken, in: localContext) {
                conversation = existingConversation
            } else if let eventDictionary = event.eventDictionary.convertToNetworkDictionary() {
                conversation = Conversation(dictionary: eventDictionary, context: localContext)
                unfetchedGroupTokens.insert(groupToken)
            } else {
                assertionFailure("Events should always be NetworkDictionary convertible")
                continue
            }
            
            guard let message = WMessage(dictionary:event.eventDictionary, conversation:conversation, context: localContext) else {
                assertionFailure("Could not decode messaging event")
                continue
            }
            
            if event.groupToken == visibleGroupToken {
                message.read = true
                readMIDs.append(message.mid)
            } else if let _ = conversation.cid {
                displayNotificationIfNeeeded(groupToken, conversation: conversation, message: message)
            }
            deliveredMIDs.append(message.mid)
        }
        
        if deliveredMIDs.count > 0 || readMIDs.count > 0 {
            system().endpointRequestOperationQueue.addOperation(UpdateStatusesForReadMessagesEndpointRequest(readMIDs: readMIDs, deliveredMIDs: deliveredMIDs))
        }
        
        /**
         * If we were missing conversation objects for some messages, refetch the list of conversations and try again
         * The FetchConversationList endpoint only returns the 100 most recent ones.
         * We might get a message from something older (following a reinstall or something)
         */
        if unfetchedGroupTokens.count > 0 {
            let fetchConversationsListRequest = FetchConversationListEndpointRequest()
            fetchConversationsListRequest.success = { _ in
                
                // We've refreshed the conversation list.  Let's see if any of the messages belong to a conversation which isn't in the list we just got.
                var groupTokensToFetchIndividually = unfetchedGroupTokens
                
                MagicalRecord.save( blockAndWait:{ (localContext) in
                    let fetchedConversations = Conversation.mr_findAll(with: NSPredicate(format: "groupToken in %@", unfetchedGroupTokens), in: localContext)
                    fetchedConversations?.forEach { conversation in
                        guard let groupToken = (conversation as? Conversation)?.groupToken else {
                            return
                        }
                        _ = groupTokensToFetchIndividually.remove(groupToken)
                    }
                })
                
                for groupToken in groupTokensToFetchIndividually {
                    let individualConversationRequest = FetchConversationEndpointRequest(groupToken: groupToken, duringReplay: false)
                    system().endpointRequestOperationQueue.addOperation(individualConversationRequest)
                }
            }
            system().endpointRequestOperationQueue.addOperation(fetchConversationsListRequest)
        }
    }
    
    func displayNotificationIfNeeeded(_ groupToken: String, conversation: Conversation, message: WMessage) {
        
        guard let user = system().user else {
            return
        }
        
        if duringReplay {
            return
        }
        
        var notificationMessage: String
        if user.shouldPromptForPIN() {
            notificationMessage = NSLocalizedString("You have a new private message", comment: "")
        } else if message.isValidGiphyMessage() {
            notificationMessage = String(format: NSLocalizedString("%@ sent you a giphy!", comment: ""), conversation.nickname())
        } else if message.hasImage {
            notificationMessage = String(format: NSLocalizedString("%@ sent you a picture!", comment: ""), conversation.nickname())
        } else {
            notificationMessage = conversation.nickname()
            if let messageText = message.text {
                notificationMessage = String(format: NSLocalizedString("%@: %@", comment: ""), conversation.nickname(), messageText)
            }
        }
        
        WStatusBarNotification.postForChat(withMessage: notificationMessage, groupToken: groupToken)
    }
}
