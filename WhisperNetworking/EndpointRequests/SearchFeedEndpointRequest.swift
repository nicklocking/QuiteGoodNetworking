class SearchFeedEndpointRequest: EndpointRequest {
    
    let feedName: String
    let searchTerm: String
    let searchTermEncoded: String
    
    required init?(feedName: Int, searchTerm: String) {
        
        self.feedName = FeedType(rawValue: feedName)?.name() ?? FeedType.generic.name()
        self.searchTerm = searchTerm
        guard let encoded = (searchTerm as NSString).whisper_urlEncoded() else {
            assertionFailure("Non-URL-encodable search term '" + searchTerm + "'")
            return nil
        }
        searchTermEncoded = encoded
        
        super.init()
        
        requiresAuthenticatedUser = true
        
        path = "/search/suggest"
        
        responseProcessorType = SearchResponseProcessor.self
        
    }
    
    override func parameters() -> NetworkDictionary {
        return super.parameters() + ["types":feedName, "query":searchTermEncoded]
    }
    
    override func createResponseProcessor() {
        responseProcessor = SearchResponseProcessor(query: searchTerm, queryTypes: [.placeAutoComplete], fetchReason: .none)
    }
    
}
