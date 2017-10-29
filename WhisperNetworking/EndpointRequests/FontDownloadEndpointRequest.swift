class FontDownloadEndpointRequest: EndpointRequest {

    let fontDictionary: NetworkDictionary
    let remoteURLString: String
    
    init?(fontDictionary: NetworkDictionary) {
        self.fontDictionary = fontDictionary
        guard let remoteURLString = fontDictionary["url"] as? String else {
            return nil
        }
        
        self.remoteURLString = remoteURLString
        
        super.init()
        responseProcessorType = FetchFontResponseProcessor.self
    }
    
    override func createResponseProcessor() {
        responseProcessor = FetchFontResponseProcessor(fontDictionary: fontDictionary)
    }
 
    override func urlString() -> String {
        return remoteURLString
    }
    
}
