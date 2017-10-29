class FetchSuggestedLocationsEndpointRequest: EndpointRequest {
    
    var feedID: String
    
    required init(feedID: String) {
        
        self.feedID = feedID
        
        super.init()
        
        path = "/user/create_places"
        
        responseProcessorType = FetchSuggestedLocationsResponseProcessor.self
    }
    
    override func parameters() -> NetworkDictionary {
        return super.parameters() + ["feed_id":feedID]
    }
    
}
