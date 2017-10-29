class FetchUserSettingsEndpointRequest: EndpointRequest {
    
    override init() {
        
        super.init()
        
        path = "/user/settings"
        
        requiresAuthenticatedUser = true
        
    }
    
}
