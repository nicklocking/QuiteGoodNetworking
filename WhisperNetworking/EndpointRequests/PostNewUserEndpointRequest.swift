class PostNewUserEndpointRequest: EndpointRequest {
    
    var work: String
    var token: String
    var publicKey: String
    
    required init?(work: String, token: String, publicKey: String) {
        
        self.work = work
        self.token = token
        self.publicKey = publicKey
        
        super.init()
        
        path = "/user/new"
        
        httpMethod = .post
        
        guard let nonceAndHmac = WSecurity.nonceAndHmacForNewUser() as? [String:String] else {
            return nil
        }
        let nonce = nonceAndHmac["nonce"]
        let hmac = nonceAndHmac["hmac"]
        
        queryParams = ["work":NSString(format: "%@%@", token, work), "token":token, "hmac":hmac, "nonce":nonce]
        
        extraParameters = ["public_key":publicKey, "locale":WhisperLocaleSettings().localePreference()]
        
        responseProcessorType = PostNewUserResponseProcessor.self
    }
    
}
