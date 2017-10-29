import Alamofire

class FetchPINResetTextEndpointRequest: EndpointRequest {
    
    override required init() {
        
        super.init()
                
        path = "/v0/user/random_whisper_text"
        
        httpMethod = .post
        
        encodingMethod = JSONEncoding.default
    }
    
    override func parameters() -> NetworkDictionary {
        guard let uid = system().user?.uid else {
            return super.parameters()
        }
        return super.parameters() + ["uid":uid, "shared_secret":UUID().uuidString]
    }
    
}
