class FetchOwnChatRatingEndpointRequest: EndpointRequest {
    
    override init() {
        super.init()
        
        requiresAuthenticatedUser = true
        
        path = "/messaging/rating"

        responseProcessorType = FetchOwnChatRatingResponseProcessor.self
        
        defaultFailureMessage = NSLocalizedString("We're having trouble getting your rating at this time. Please try again later", comment: "")
    }
    
}