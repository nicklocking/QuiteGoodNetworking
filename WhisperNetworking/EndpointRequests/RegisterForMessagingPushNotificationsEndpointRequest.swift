class RegisterForMessagingPushNotificationsEndpointRequest: MessagingEndpointRequest {
    
    required override init() {
        
        super.init()
        
        path = "/v1/push"
        
        httpMethod = .post
    }
    
    override func parameters() -> NetworkDictionary {
        if let apnTokenString = system().user?.apnTokenString() {
            return super.parameters() + ["token":apnTokenString, "service":"APN"]
        }
        return super.parameters()
    }
    
    override func copy(with zone: NSZone?) -> Any {
        return RegisterForMessagingPushNotificationsEndpointRequest()
    }
}
