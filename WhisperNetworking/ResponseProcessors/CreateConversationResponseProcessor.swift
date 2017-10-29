class CreateConversationResponseProcessor: CoreDataResponseProcessor {
    
    var cid: String
    var originName: String?
    var feedID: String?
    var reply: Bool
    var statusCode: Int
    var feedName: String?
    
    required init(cid: String, originName: String?, feedID: String?, feedName: String?, reply: Bool, statusCode: Int) {
        
        self.cid = cid
        self.originName = originName
        self.feedID = feedID
        self.reply = reply
        self.statusCode = statusCode
        self.feedName = feedName
        
        super.init()
    }
    
    @available(*, deprecated: 1.0, message: "init not implemented; causes fatalError")
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func processWithLocalContext(_ localContext: NSManagedObjectContext) {
        guard
            let conversation = Conversation.mr_findFirst(byAttribute: "localCid", withValue: cid, in: localContext),
            let conversationJSON = responseDictionary()?["conversation"] as? NetworkDictionary else
        {
            return
        }
        
        conversation.setValuesForKeysWithJSONDictionary(conversationJSON)
    }
    
    override func processErrorResponse() {
        MagicalRecord.save({ (localContext) in
            let chatConversationCreateErrorDefault = 0
            let chatConversationCreateErrorBlocked = 1
            
            let errorReason = self.statusCode == .forbidden ? chatConversationCreateErrorBlocked : chatConversationCreateErrorDefault
            
            guard let conversation = Conversation.mr_findFirst(byAttribute: "localCid", withValue: self.cid, in: localContext) else {
                return
            }
            
            if let name = conversation.creationNotificationName() {
                NotificationCenter.default.postNotificationOnMainThread(Notification.Name(rawValue: name), object: nil, userInfo: [WUserInfoBoolKey:false, WUserInfoIntegerKey:errorReason])
            }
            WTracker.shared().trackMessagingConversationCreateError(conversation.wid, statusCode: self.statusCode, originName: self.originName, feedID: self.feedID, reply: self.reply)
        })
    }
    
    override func performAfterSave() {
        MagicalRecord.save({ (localContext) in
            guard let conversation = Conversation.mr_findFirst(byAttribute: "localCid", withValue: self.cid, in: localContext) else {
                return
            }
            
            if let name = conversation.creationNotificationName() {
                NotificationCenter.default.postNotificationOnMainThread(NSNotification.Name(rawValue: name ), object: nil, userInfo: [WUserInfoBoolKey:true])
            }
            WTracker.shared().trackMessagingConversationCreated(conversation.wid, originName: self.originName, feedID: self.feedID, feedName: self.feedName, reply: self.reply)
        })
    }
    
}
