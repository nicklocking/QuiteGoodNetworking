import Foundation

class SearchResponseProcessor: CoreDataResponseProcessor {
    
    let query: String
    let queryTypes: [SearchQueryType]
    let fetchReason: FeedFetchReason
    var isSearchingForLocations = false
    
    var reachedEndOfList: Bool {
        return responseStatusCode == .noContent
    }
    
    var scrollIDForQuery = [SearchQueryType: String]()
    
    @objc convenience init(query: String, queryType: SearchQueryType, fetchReason: FeedFetchReason) {
        self.init(query: query, queryTypes: [queryType], fetchReason: fetchReason)
    }
    
    required init(query: String, queryTypes: [SearchQueryType], fetchReason: FeedFetchReason) {
        self.query = query
        self.queryTypes = queryTypes
        self.fetchReason = fetchReason
        super.init()
    }
    
    @available(*, deprecated: 1.0, message: "init not implemented; causes fatalError")
    required init() {
        fatalError("init() has not been implemented")
    }
    
    
    override func processWithLocalContext(_ localContext: NSManagedObjectContext) {
        
        guard !reachedEndOfList else {
            // No content
            return
        }
        
        guard let responses = responseDictionary() else {
            assertionFailure()
            return
        }
        
        queryTypes.forEach { (queryType) in
            
            var queryResponses: Any?
            var scrollID: String?
            
            if queryType == .placeAutoComplete {
                
                queryResponses = responses[queryType.name()] as? [NetworkDictionary]
                
            } else if queryType == .place && isSearchingForLocations {
                
                queryResponses = responses["locations"] as? [NetworkDictionary]
                
            } else if
                let queryResponse = responses[queryType.name()] as? NetworkDictionary,
                let localScrollID = queryResponse["scroll_id"] as? String
            {
                scrollID = localScrollID
                scrollIDForQuery[queryType] = localScrollID
                queryResponses = queryResponse["items"]
                
            } else if let queryResponse = responses[queryType.name()] as? NetworkDictionary {
                
                queryResponses = queryResponse["items"]
                
            }
            
            guard let results = queryResponses as? [NetworkDictionary] else {
                assertionFailure("No results for query type \(queryType)")
                return
            }

            
            switch queryType {
            case .tribe:
                let searchProcessor = SearchFeedsResponseSubprocessor(query: query, feedType: .tribe, feedDictionaries: results)
                searchProcessor.processWithLocalContext(localContext)
                
                if fetchReason != .scrollingIntoNewPage {
                    TrackingEvent(name: "Tribe Searched", standardProperties: ["search_term":query, "num_results":results.count]).submit()
                }
            case .place, .placeAutoComplete:
                let searchProcessor = SearchFeedsResponseSubprocessor(query: query, feedType: .place, feedDictionaries: results)
                searchProcessor.processWithLocalContext(localContext)
            case .whisper:
                let searchProcessor = SearchWhispersResponseSubprocessor(query: query,
                    whisperDictionaries: results,
                    feedFetchReason: fetchReason,
                    responseScrollID: scrollID)
                searchProcessor.processWithLocalContext(localContext)
            }
        }
    }
    
}
