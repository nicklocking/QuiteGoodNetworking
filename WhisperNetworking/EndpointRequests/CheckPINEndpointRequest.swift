class CheckPINEndpointRequest: EndpointRequest {
    
    var pin: String
    var uid: String
    
    required init(pin: String, uid: String, isVerify: Bool) {
        
        self.pin = pin
        self.uid = uid
        
        super.init()
        
        requiresAuthenticatedUser = !isVerify
        
        path = "/user/validate"
    }
    
    override func parameters() -> NetworkDictionary {
        return super.parameters() + ["pin":pin, "uid":uid]
    }
    
    override func didFailRequest() {
        super.didFailRequest()
        WTracker.shared().trackPINFail()
    }
    
    override func didCompleteRequestSuccessfully() {
        system().user?.updatePIN(self.pin)
        super.didCompleteRequestSuccessfully()
    }
}
