class UpdateUserEndpointRequest: EndpointRequest {
    
    var onlyFirstPage: Bool
    var updateLanguage: Bool
    var isReinstall: Bool
    
    required init(scrollID: String?, onlyFirstPage: Bool, updateLanguage: Bool, isReinstall: Bool) {
        
        self.onlyFirstPage = onlyFirstPage
        self.updateLanguage = updateLanguage
        self.isReinstall = isReinstall
        
        super.init()
        
        requiresAuthenticatedUser = true
        
        path = "/user/activity"
        
        responseProcessorType = UpdateUserResponseProcessor.self
        
        extraParameters = ["scroll_id":scrollID]
    }
    
    override func createResponseProcessor() {
        super.createResponseProcessor()
        
        if let localResponseProcessor = responseProcessor as? UpdateUserResponseProcessor {
            localResponseProcessor.onlyFirstPage = onlyFirstPage
            localResponseProcessor.updateLanguage = updateLanguage
            localResponseProcessor.isReinstall = isReinstall
        }
    }
    
}
