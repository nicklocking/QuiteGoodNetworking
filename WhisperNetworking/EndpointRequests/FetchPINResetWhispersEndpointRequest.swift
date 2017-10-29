class FetchPINResetWhispersEndpointRequest: EndpointRequest {
    
    override required init() {
        
        super.init()
        
        requiresAuthenticatedUser = true
        
        path = "/whispers/latest"
    }
    
}

