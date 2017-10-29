class DeleteConversationsResponseProcessor: CoreDataResponseProcessor {
    
    var isBan = false
    var cids = [String]()
    var conversationNotificationNames = Array<Notification.Name>()
    
    override func processWithLocalContext(_ localContext: NSManagedObjectContext) {
        
        let predicate = NSPredicate(format: "cid IN %@", cids)
        
        if let conversations = Conversation.mr_findAll(with: predicate, in: localContext) as? [Conversation] {
            for conversation in conversations {
                if let name = conversation.deletionNotificationName() {
                    conversationNotificationNames.append( Notification.Name(rawValue:name) )
                }
            }
        }

        Conversation.mr_deleteAll(matching: predicate, in: localContext)
    }
    
    override func performAfterSave() {
        for conversationName in conversationNotificationNames {
            NotificationCenter.default.postNotificationOnMainThread(conversationName, object: nil, userInfo: [WUserInfoBoolKey:isBan])
        }
    }
}
