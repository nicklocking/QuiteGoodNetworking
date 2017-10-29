class VotePollEndpointRequest: EndpointRequest {
    
    var pollID: String
    var optionID: String
    var feedID: String
    
    required init(feedID: String, optionID: String, pollID: String) {
        self.pollID = pollID
        self.optionID = optionID
        self.feedID = feedID
        
        super.init()
        
        requiresAuthenticatedUser = true
        if let userID = system().user?.uid {
            path = "/polls/vote/" + userID
        }
        httpMethod = .post
    }
    
    override func parameters() -> NetworkDictionary {
        return super.parameters() + ["poll_id":pollID,"option_id":optionID,"feed_id":feedID]
    }
    
}
