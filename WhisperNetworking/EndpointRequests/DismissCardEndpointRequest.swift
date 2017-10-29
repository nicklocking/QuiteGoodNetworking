class DismissCardEndpointRequest: EndpointRequest {
    
    var cardID: String
    var cardTypeName: String
    var feedID: String
    var index: Int
    var pollID: String?
    var origin: String?
    
    required init(cardID: String, cardTypeName: String, feedID: String, index: Int, pollID: String?, origin: String?) {
        
        self.cardID = cardID
        self.cardTypeName = cardTypeName
        self.feedID = feedID
        self.index = index
        self.pollID = pollID
        self.origin = origin
        
        super.init()
        
        requiresAuthenticatedUser = true
        
        path = "/cards/feedback"
        
        guard let uid = system().user?.uid else {
            return
        }

        queryParams = ["card_id":cardID, "action":"dismiss", "origin":origin, "uid":uid]
        
        httpMethod = .post
    }
    
    override func didCompleteRequestSuccessfully() {
        super.didCompleteRequestSuccessfully()
        WTracker.shared().trackFeedCardDismissed(withCardID: cardID, andType: cardTypeName, withFeedID: feedID, at: index, pollID: pollID)
    }
}
