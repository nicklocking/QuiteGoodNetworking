class RegisterForWhisperPushNotificationsEndpointRequest: EndpointRequest {
    
    required init?(junkParameter: Bool) {
        
        super.init()
        
        requiresAuthenticatedUser = true
        
        path = "/user/token"
        
        httpMethod = .post
        
        
        guard let localPUID = system().user?.puid else {
            assertionFailure("Cannot register for push notifications without a puid")
            return nil
        }
        
        queryParams = ["puid":localPUID]
        
        extraParameters = ["token":system().user?.apnTokenString(), "type":"ios"]
    }
    
    override func didFailRequest() {
        WTracker.shared().trackGeneralPushRegistrationDidFail(statusCode())
        super.didFailRequest()
    }
    
    override func copy(with zone: NSZone?) -> Any {
        return RegisterForWhisperPushNotificationsEndpointRequest(junkParameter: true)!
    }
    
}
