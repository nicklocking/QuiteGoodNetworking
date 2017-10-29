class RequestNotificationForFeedEndpointRequest: EndpointRequest {
    
    var feedID: String

    required init(feedID: String) {
        
        self.feedID = feedID
    
        super.init()
        
        path = "/feeds/request_notification"
        
        httpMethod = .post
        
        extraParameters = ["uid":system().user?.uid, "feed_id":feedID]
    }
}
