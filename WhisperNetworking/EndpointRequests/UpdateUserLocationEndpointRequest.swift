class UpdateUserLocationEndpointRequest: EndpointRequest {
    
    var source: String
    var meta: String
    
    required init(source: String, meta: String) {
        
        self.source = source
        self.meta = meta
        
        super.init()
        
        requiresAuthenticatedUser = true
        
        guard let uid = system().user?.uid  else {
            return
        }
        
        path = "/user/location/\(uid)/\(source)"
        
        queryParams = ["metadata":meta]
        
        httpMethod = .post
    }
    
}
