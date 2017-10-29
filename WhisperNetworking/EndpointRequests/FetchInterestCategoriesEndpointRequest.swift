class FetchInterestCategoriesEndpointRequest: EndpointRequest {
    
    override init() {
        
        super.init()
        
        requiresAuthenticatedUser = true
        
        path = "/feeds/interests"
        
        responseProcessorType = FetchInterestCategoriesResponseProcessor.self
    }
    
}
