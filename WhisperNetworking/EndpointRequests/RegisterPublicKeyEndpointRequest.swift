class RegisterPublicKeyEndpointRequest: EndpointRequest {
    
    var work: String
    var token: String
    var publicKey: String
    var uid: String
    
    required init?(work: String, token: String, publicKey: String, uid: String) {
        
        self.work = work
        self.token = token
        self.publicKey = publicKey
        self.uid = uid
        
        super.init()
        
        path = "/user/update"
        
        httpMethod = .post
        
        guard
            let nonceAndHmac = WSecurity.nonceAndHmacForNewUser().convertToNetworkDictionary(),
            let nonce = nonceAndHmac["nonce"],
            let hmac = nonceAndHmac["hmac"] else
        {
            return nil
        }
        
        queryParams = ["work":"\(token)\(work)", "token":token, "hmac":hmac, "nonce":nonce, "uid":uid]
        
        extraParameters = ["public_key":publicKey]
    }
    
}
