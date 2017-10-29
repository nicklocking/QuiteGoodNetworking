class ChangePINEndpointRequest: EndpointRequest {
    
    var oldPIN: String?
    var newPIN: String
    
    required init?(oldPIN: String?, newPIN: String) {
        
        self.oldPIN = oldPIN
        self.newPIN = newPIN
        
        super.init()
        
        path = "/user/pin"
        
        httpMethod = .post
        
        defaultFailureMessage = "Your PIN could not be set at this time. Please try again shortly."
        
        guard let uid = system().user?.uid,
        let queryAuthParams = WSecurity.legacyAuthenticationParams(forPIN: oldPIN, uid: uid) as? NetworkDictionary,
            let authToken = queryAuthParams["auth_token"],
            let nonce = queryAuthParams["nonce"] else {
                return nil
        }
        
        queryParams = ["uid":uid, "auth_token":authToken, "nonce":nonce]
        
        extraParameters = ["pin":newPIN, "uid":uid]
    }
    
}
