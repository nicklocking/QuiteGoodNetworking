class ReplayConversationResponseProcessor: CoreDataResponseProcessor {
    
    var conversationManagedObjectID: NSManagedObjectID!
    
    override func processWithLocalContext(_ localContext: NSManagedObjectContext) {
        
        let replayedConversation = Conversation.mr_findFirst(with: NSPredicate(format: "self == %@", conversationManagedObjectID), in: localContext)
        
        guard
            let localResponseDictionary = responseDictionary(),
            let tigertextAPI = localResponseDictionary["tigertext_api"] as? NetworkDictionary,
            let messages = tigertextAPI["reply"] as? [[AnyHashable: Any]],
            let user = system().user else
        {
            assertionFailure()
            return
        }
        
        var mids = [String]()
        for messageDictionary in messages {
            // TODO: Replace the WCore method with MessagesReceivedResponseProcessor
            let message = WCore().addMessage(messageDictionary, conversation: replayedConversation, user: user, in: localContext)
            message?.read = true
            if message?.mine != true {
                mids.append((message?.mid)!)
            }
        }
        
        if mids.count == 0 {
            return
        }
        
        if mids.count > 1 {
            WRemote.shared().expectedReadMIDs.addObjects(from: mids)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: {
                WRemote.shared().sendQueuedReadEvents()
            })
        }
        
        system().endpointRequestOperationQueue.addOperation(UpdateStatusesForReadMessagesEndpointRequest(readMIDs: mids, deliveredMIDs: mids))
    }
    
}
