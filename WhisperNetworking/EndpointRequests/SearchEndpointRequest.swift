import Foundation

/**
 * Use SearchScrollEndpointRequest for subsequent pages
 */
class SearchEndpointRequest: EndpointRequest {
    
    let query: String
    let queryTypes: [SearchQueryType]
    
    @objc convenience init(query: String, queryTypeNumbers: NSArray, limit: NSNumber?) {
        let queryTypes: [SearchQueryType] = queryTypeNumbers.flatMap {
            guard let queryType = $0 as? NSNumber else {
                return nil
            }
            return SearchQueryType(rawValue: queryType.intValue)
        }
        self.init(query: query, queryTypes: queryTypes, limit: limit?.intValue)
    }
    
    required init(query: String, queryTypes: [SearchQueryType], limit: Int? = nil, scrollID: String? = nil) {
        
        self.query = query
        self.queryTypes = queryTypes
        
        super.init()
        
        path = "/search"
        
        requiresAuthenticatedUser = true
        
        extraParameters = [
            "query_type": queryTypes.map({$0.name()}).joined(separator: ","),
            "query": query.data(using: String.Encoding.utf8)?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)),
            "limit": limit,
            "scroll_id": scrollID
        ]
    }
    
    override func createResponseProcessor() {
        responseProcessor = SearchResponseProcessor(query: query, queryTypes: queryTypes, fetchReason: .none)
    }
}
