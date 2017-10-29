class SubmitUserFeedbackEndpointRequest: EndpointRequest {
    
    var body: String
    var rating: Int
    
    required init(body: String?, rating: Int) {
        
        self.body = body ?? ""
        self.rating = rating
        
        super.init()
        
        requiresAuthenticatedUser = true
        
        path = "/review/feedback"
        
        httpMethod = .post
        
        extraParameters = [
            "uid":system().user?.uid,
            "body":body,
            "number_of_stars":rating
        ]
    }
    
}
