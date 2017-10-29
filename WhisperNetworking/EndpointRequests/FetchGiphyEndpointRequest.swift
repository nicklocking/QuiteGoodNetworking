class FetchGiphyEndpointRequest: EndpointRequest {
    
    var searchText: String
    
    override var baseURLString: String { return "http://api.giphy.com" }
    
    required init(searchText: String) {
        
        self.searchText = searchText
        
        super.init()
        
        path = "/v1/gifs/search"
        
        extraParameters = ["api_key":UserDefaults.standard.string(forKey: WUserDefaultsGiphyAPIKey),
                           "limit":100,
                           "q":searchText,
                           "rating": (system().user?.isHideNSFWEnabled == true) ? "pg-13" : "r"]
        
        responseProcessorType = FetchGiphyResponseProcessor.self
    }
    
    override func didCompleteRequestSuccessfully() {
        TrackingEvent(name: "Gif Search", standardProperties: ["Search Term":searchText]).submit()
        super.didCompleteRequestSuccessfully()
    }
}
