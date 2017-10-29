class FetchWhisperMediaEndpointRequest: EndpointRequest {
    
    var whisperText: String
    var parentWID: String?
    var searchTerm: String?
    var scrollID: String?
    var contentType: ContentType
    
    required init(whisperText: String, parentWID: String?, searchTerm: String?, scrollID: String?, contentType: ContentType) {
        
        self.whisperText = whisperText
        self.parentWID = parentWID
        self.searchTerm = searchTerm
        self.scrollID = scrollID
        self.contentType = contentType
        
        super.init()
        
        requiresAuthenticatedUser = true
        
        if let _ = searchTerm {
            path = "/search_media/"
        } else {
            path = "/search_media/suggest/"
        }
        
        responseProcessorType = FetchWhisperMediaResponseProcessor.self
        
        
        extraParameters = ["parent_wid":parentWID] + WLocationManager.shared().location?.dictionaryRepresentation().convertToNetworkDictionary()
        
        let queryParam = searchTerm ?? whisperText
        
        if let stringData = queryParam.data(using: String.Encoding.utf8) {
            extraParameters?["query"] = stringData.base64EncodedString(options: .lineLength64Characters)
        }
        
        if let localScrollID = scrollID {
            extraParameters?["scroll_id"] = localScrollID
        }
        
        switch contentType {
        case .image:
            extraParameters?["media_types"] = "image"
        case .video:
            extraParameters?["media_types"] = "video"
        case .both:
            extraParameters?["media_types"] = "image,video"
        }
    }
    
    override func createResponseProcessor() {
        responseProcessor = FetchWhisperMediaResponseProcessor(searchTerm: searchTerm)
    }
    
}
