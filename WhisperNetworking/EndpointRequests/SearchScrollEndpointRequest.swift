import Foundation

class SearchScrollEndpointRequest: EndpointRequest {
    
    let query: String
    let queryTypes: [SearchQueryType]
    
    required init(scrollID: String, query: String, queryTypes: [SearchQueryType], limit: Int? = nil) {
        
        self.query = query
        self.queryTypes = queryTypes
        
        super.init()
        
        path = "/search_scroll"
        
        requiresAuthenticatedUser = true
        
        extraParameters = [
            "scroll_id": scrollID,
            "limit": limit
        ]
    }
    
    override func createResponseProcessor() {
        responseProcessor = SearchResponseProcessor(query: query, queryTypes: queryTypes, fetchReason: .scrollingIntoNewPage)
    }
}
