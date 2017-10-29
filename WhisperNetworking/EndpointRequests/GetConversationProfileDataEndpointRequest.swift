class GetConversationProfileDataEndpointRequest: EndpointRequest {
    
    var wid: String
    var conversationManagedObjectID: NSManagedObjectID
    
    required init(wid: String, conversationManagedObjectID: NSManagedObjectID) {
        
        self.wid = wid
        self.conversationManagedObjectID = conversationManagedObjectID
        
        super.init()
        
        requiresAuthenticatedUser = true
        
        path = "/messaging/conversation/profile"
        
        extraParameters = ["uid":system().user?.uid, "wid":wid]
        
        responseProcessorType = GetConversationProfileDataResponseProcessor.self
    }
    
    override func createResponseProcessor() {
        responseProcessor = GetConversationProfileDataResponseProcessor(conversationManagedObjectID: conversationManagedObjectID)
    }
}
