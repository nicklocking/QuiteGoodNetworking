class ReplayConversationEndpointRequest: MessagingEndpointRequest {
    
    var groupToken: String
    var conversationManagedObjectID: NSManagedObjectID
    
    required init(groupToken: String, messageCount: Int, conversationManagedObjectID: NSManagedObjectID, wid: String?, cid: String?) {
        
        self.groupToken = groupToken
        self.conversationManagedObjectID = conversationManagedObjectID
        
        super.init()
        
        path = "/v1/message/replay/\(groupToken)"
        
        let trackingProperties: NetworkOptionalsDictionary = ["First Launch":WTracker.shared().isFirstLaunch(),
                                                       "Total Launches":WTracker.shared().totalLaunches(),
                                                       "operation_name":"replay_conversation",
                                                       "wid":wid,
                                                       "cid":cid,
                                                       "Group Token":groupToken,
                                                       "Message Count":messageCount]
        
        
        errorTrackingProperties = trackingProperties
        
        responseProcessorType = ReplayConversationResponseProcessor.self

    }
    
    override func createResponseProcessor() {
        super.createResponseProcessor()
        
        if let localResponseProcessor = responseProcessor as? ReplayConversationResponseProcessor {
            localResponseProcessor.conversationManagedObjectID = conversationManagedObjectID
        }
    }

}
