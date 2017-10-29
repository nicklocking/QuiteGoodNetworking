class CreateConversationEndpointRequest: EndpointRequest {
    
    var wid: String
    var originName: String?
    var recommender: String
    var cid: String
    var feedID: String?
    var reply: Bool
    var feedName: String?
    
    required init(wid: String, originName: String?, recommender: String, cid: String, feedID: String?, feedName: String?, reply: Bool) {
        
        self.wid = wid
        self.originName = originName
        self.recommender = recommender == "" ? "(none)" : recommender
        self.cid = cid
        self.feedID = feedID
        self.feedName = feedName
        self.reply = reply
        
        super.init()
        
        requiresAuthenticatedUser = true
        
        guard let uid = system().user?.uid else {
            return
        }
        
        path = "/messaging/conversation/\(wid)/\(uid)"
        
        queryParams = ["origin":originName, "recommender":recommender]
        
        httpMethod = .post
        
        responseProcessorType = CreateConversationResponseProcessor.self
        
        var properties: NetworkOptionalsDictionary = ["operation_name":"create_conversation"]
        
        if let localOriginName = originName {
            properties += ["origin":localOriginName]
        } else {
            properties += ["origin":"none"]
        }
        
        properties += ["source_feed_name":feedName]
        
        properties += ["recommender":recommender]
        
        properties += ["First Launch":WTracker.shared().isFirstLaunch(), "Total Launches":WTracker.shared().totalLaunches()]
        
        errorTrackingProperties = properties
    }
    
    override func createResponseProcessor() {
        responseProcessor = CreateConversationResponseProcessor(cid: cid, originName: originName, feedID: feedID, feedName: feedName, reply: reply, statusCode: statusCode())
    }
    
}
