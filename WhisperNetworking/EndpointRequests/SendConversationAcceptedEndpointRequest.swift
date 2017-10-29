class SendConversationAcceptedEndpointRequest: EndpointRequest {
    
    var cid: String
    
    required init(cid: String) {
        
        self.cid = cid
        
        super.init()
        
        requiresAuthenticatedUser = true
        
        path = "/messaging/conversations/accept"
        
        httpMethod = .post
        
        extraParameters = ["uid":system().user?.uid, "conversation_id":cid]
    }
}
