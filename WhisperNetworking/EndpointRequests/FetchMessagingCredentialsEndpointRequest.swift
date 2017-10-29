class FetchMessagingCredentialsEndpointRequest: EndpointRequest {
    
    required override init() {
        super.init()
        
        requiresAuthenticatedUser = true
        
        path = "/messaging/conversations/tt_auth"
        
        responseProcessorType = FetchMessagingCredentialsResponseProcessor.self
    }
}
