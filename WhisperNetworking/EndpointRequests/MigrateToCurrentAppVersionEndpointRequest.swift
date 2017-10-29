class MigrateToCurrentAppVersionEndpointRequest: EndpointRequest {
    
    static let needToCallUserMigrateKey =  "need_to_call_user_migrate"
    
    required init?(junkParameter: Bool) {
        
        super.init()
        
        path = "/user/migrate"
        
        requiresAuthenticatedUser = true
        
        httpMethod = .post
        
        guard let localUID = system().user?.uid else {
            assertionFailure("Cannot migrate user without a uid")
            return nil
        }
        
        queryParams = ["uid":localUID]

        extraParameters = ["to_version":"ios_\(WDevice.whisperVersion())"]
        errorTrackingProperties = super.parameters()
    }
    
    override func didCompleteRequestSuccessfully() {
        super.didCompleteRequestSuccessfully()
        
        UserDefaults.standard.set(false, forKey: MigrateToCurrentAppVersionEndpointRequest.needToCallUserMigrateKey)
    }
}
