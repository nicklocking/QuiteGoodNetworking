class SearchForLocationsEndpointRequest: EndpointRequest {
    
    var searchTerm: String
    var latitude: Double
    var longitude: Double
    
    required init(searchTerm: String, latitude: Double, longitude: Double) {
        
        self.searchTerm = searchTerm
        self.latitude = latitude
        self.longitude = longitude
        
        super.init()
        
        path = "/search/suggest/autocomplete"
        
        extraParameters = ["query":searchTerm]
    }
    
    override func createResponseProcessor() {
        let localResponseProcessor = SearchResponseProcessor(query: searchTerm, queryType: .place, fetchReason: .none)
        localResponseProcessor.isSearchingForLocations = true
        responseProcessor = localResponseProcessor
    }
}
