class UnlockDebugSettingsEndpointRequest: EndpointRequest {
    
    var code: String
    
    required init(code: String) {
        
        self.code = code
        
        super.init()
        
        requiresAuthenticatedUser = true
        
        path = "/debug/menu"
    }
    
    override func parameters() -> NetworkDictionary {
        guard let uid = system().user?.uid else {
            return super.parameters()
        }
        return super.parameters() + ["password":WSecurity.md5String("\(uid):notouching:\(code)")]
    }
    
}
