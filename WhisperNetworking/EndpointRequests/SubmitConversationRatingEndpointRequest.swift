class SubmitConversationRatingEndpointRequest: EndpointRequest {
    
    var rating: Int
    var cid: String
    
    required init(rating: Int, cid: String) {
        
        self.rating = rating
        self.cid = cid
        
        super.init()
        
        requiresAuthenticatedUser = true
        
        path = "/messaging/rate"
        
        httpMethod = .post
        
        extraParameters = ["uid":system().user?.uid, "rating":rating, "conversation_id":cid]
    }
    
}
