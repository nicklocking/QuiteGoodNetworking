class AddWhisperToFeedEndpointRequest: EndpointRequest {
    
    var feedID: String
    var whisperID: String
    
    required init(feedID: String, whisperID: String) {
        
        self.feedID = feedID
        self.whisperID = whisperID
        
        super.init()
        
        requiresAuthenticatedUser = true
        
        guard let uid = system().user?.uid  else {
            return
        }
        
        path = "/feeds/add"
        
        queryParams = ["feed_id":feedID, "wid": whisperID, "uid": uid]
        
        httpMethod = .post
    }
    
    
    override func parameters() -> NetworkDictionary {
        var params = super.parameters()
        params["feed_id"] = feedID
        params["wid"] = whisperID
        return params
    }
    
}
