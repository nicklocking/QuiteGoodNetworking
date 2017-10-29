class FlagWhisperEndpointRequest: EndpointRequest {
    
    var wid: String
    var reason: String?
    var source: String?
    var recommender: String?
    
    required init(wid: String, reason: String?, source: String?, recommender: String?) {
        
        self.wid = wid
        self.reason = reason
        self.source = source
        self.recommender = recommender
        
        super.init()
        
        requiresAuthenticatedUser = true
        
        path = "/whisper/flag"
        
        httpMethod = .post
        
        responseProcessorType = FlagWhisperResponseProcessor.self
        
        extraParameters = [
            "wid":wid,
            "recommender":recommender,
            "reason":reason,
            "origin":source
        ]
    }
    
    override func createResponseProcessor() {
        responseProcessor = FlagWhisperResponseProcessor(wid: wid)
    }
}
