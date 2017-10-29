import Foundation

class SearchWhispersResponseSubprocessor {
    
    let query: String
    
    fileprivate let whispersForFeedResponseProcessor: FetchWhispersForFeedResponseProcessor
    
    required init(query: String, whisperDictionaries: [NetworkDictionary], feedFetchReason: FeedFetchReason, responseScrollID: String?) {
        self.query = query
        
        whispersForFeedResponseProcessor = FetchWhispersForFeedResponseProcessor(feedID: WhisperSearchFeed.feedIDForQuery(query), feedType: .whisperSearch, statusCode: 200, fetchReason: feedFetchReason)
        var responseDictionary: NetworkDictionary = ["whispers": whisperDictionaries]
        if let scrollID = responseScrollID {
            responseDictionary["scroll_id"] = scrollID
        }
        whispersForFeedResponseProcessor.responseJSON = responseDictionary.withoutNilKeys()
    }
    
    
    func processWithLocalContext(_ localContext: NSManagedObjectContext) {
        
        let searchFeed = WhisperSearchFeed.mr_findFirstOrCreate(byAttribute: WhisperSearchFeed.idKey,
                                                                           withValue: WhisperSearchFeed.feedIDForQuery(query),
                                                                           in: localContext)
        
        searchFeed.query = query
        WhisperSearchFeed.mr_deleteAll(matching: NSPredicate(format: "self != %@", searchFeed), in: localContext)
        
        whispersForFeedResponseProcessor.processWithLocalContext(localContext)
    }
}
