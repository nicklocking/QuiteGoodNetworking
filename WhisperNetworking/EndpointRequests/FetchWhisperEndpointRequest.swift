class FetchWhisperEndpointRequest: EndpointRequest {
    
    var wid: String
    
    required init(wid: String) {
        self.wid = wid
        
        super.init()
        path = "/whisper"
        responseProcessorType = FetchWhisperResponseProcessor.self
    }
    
    override func parameters() -> NetworkDictionary {
        return super.parameters() + ["wid":wid]
    }
    
    override func canReplaceOperation(_ operation: Operation) -> Bool {

        if let fetchWhisperEndpointRequest = operation as? FetchWhisperEndpointRequest ,
            fetchWhisperEndpointRequest.wid == wid {
            return true
        } else {
            return false
        }
        
    }
    
}
