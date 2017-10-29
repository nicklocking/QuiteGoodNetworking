class FetchShortURLForWIDEndpointRequest: EndpointRequest {
    
    var wid: String
    
    required init(wid: String) {
        
        self.wid = wid
        
        super.init()
        
        path = "/whisper/shortened/" + wid
        
        responseProcessorType = FetchShortURLForWIDResponseProcessor.self
    }
    
    
    override func createResponseProcessor() {
        responseProcessor = FetchShortURLForWIDResponseProcessor(wid: wid)
    }
    
}