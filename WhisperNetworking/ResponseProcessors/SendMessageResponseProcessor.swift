class SendMessageResponseProcessor: CoreDataResponseProcessor {
    
    var localMID = ""
    
    override func processWithLocalContext(_ localContext: NSManagedObjectContext) {
        
        guard let sentMessage = WMessage.mr_findFirst(byAttribute: "localMid", withValue: localMID, in: localContext) else {
            return
        }
        
        if
            let localHeaderFields = responseHeaders,
            let ttXMID = localHeaderFields["TT-X-Message-Id"] as? String,
            responseStatusCode == .noContent
        {
            sentMessage.mid = ttXMID
        }
        else if
            let tigertextDictionary = responseDictionary()?["tigertext_api"] as? NetworkDictionary,
            let messageDictionary = tigertextDictionary["reply"] as? [AnyHashable: Any],
            responseStatusCode == .ok
        {
            sentMessage.update(withPostResponseDictionary: messageDictionary)
        }
        else {
            processErrorResponseWithLocalContext(localContext)
        }
    }
    
    func processErrorResponseWithLocalContext(_ localContext: NSManagedObjectContext) {
        
        guard let sentMessage = WMessage.mr_findFirst(byAttribute: "localMid", withValue: self.localMID, in: localContext) else {
            return
        }
        
        if
            let tigertextDictionary = responseDictionary()?["tigertext_api"] as? NetworkDictionary,
            let error = tigertextDictionary["error"] as? String
        {
            if let messageDictionary = tigertextDictionary["reply"] as? [AnyHashable: Any], error == "reply" {
                sentMessage.update(withPostResponseDictionary: messageDictionary)
                return
            }
        }
        
        var errorType = WChatMessagingError.default
        
        if let
            localErrorResponseDictionary = self.errorJSON?.dictionaryObject?["tigertext_api"] as? NetworkDictionary,
            let error = localErrorResponseDictionary["error"] as? String,
            error == "Recipient not found"
        {
            errorType = .blocked
        }
        
        if let name = sentMessage.conversation.errorNotificationName() {
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: name),
                object: nil,
                userInfo: [WUserInfoIntegerKey : NSNumber(value: errorType.rawValue as Int)])
        }
    
        sentMessage.failed = true
    }
    
    override func processErrorResponse() {
        MagicalRecord.save({ localContext in
            self.processErrorResponseWithLocalContext(localContext)
        })
        
    }
    
}
