class FetchNewUserChallengeEndpointRequest: EndpointRequest {
    
    override init() {
        
        super.init()
        
        path = "/user/new"
        
        responseProcessorType = FetchNewUserChallengeResponseProcessor.self
    }
}
