class SendInterestedCategoriesEndpointRequest: EndpointRequest {

    var feedIDs: [String]
    var feedNames: [String]
    
    required init(feedIDs: [String], feedNames: [String]) {
        
        self.feedIDs = feedIDs
        self.feedNames = feedNames
        
        super.init()
        
        requiresAuthenticatedUser = true
        
        path = "/feeds/interests"
        
        httpMethod = .post
        
        extraParameters = ["feed_ids":feedIDs.joined(separator: ",")]
    }
    
    override func didCompleteRequestSuccessfully() {
        TrackingEvent(name: "Add Interests Completed", standardProperties: ["source_feed_id":feedIDs,"source_feed_name":feedNames]).submit()
        super.didCompleteRequestSuccessfully()
    }
}
