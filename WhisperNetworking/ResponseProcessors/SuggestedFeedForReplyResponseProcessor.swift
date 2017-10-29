import Foundation

@objc class SuggestedFeedForReplyResponseProcessor: CoreDataResponseProcessor {
    
    var replyWID: String
    var suggestedFeedObjectID: NSManagedObjectID?
    
    required init(replyWID: String) {
        self.replyWID = replyWID
    }
    
    @available(*, deprecated: 1.0, message: "init not implemented; causes fatalError")
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func processWithLocalContext(_ localContext: NSManagedObjectContext) {
        
        guard
            let response = responseDictionary(),
            let suggestedDictionary = response["suggested"] as? [String: Any],
            let feedDictionary = suggestedDictionary["feed"] as? NetworkDictionary,
            let feedID = feedDictionary["id"] else
        {
            return
        }
        
        let feed = TribeSearchFeed.mr_findFirstOrCreate(byAttribute: FeedItem.idKey, withValue: feedID, in: localContext)
        feed.setValuesForKeysWithJSONDictionary(feedDictionary, keyPrefix: "")
        feed.query = "reply_suggested_feed." + replyWID
        
        do {
            try localContext.obtainPermanentIDs(for: [feed])
            self.suggestedFeedObjectID = feed.objectID
        } catch {
            assertionFailure("Couldn't obtain permanent object id for search feed")
        }
        
    }
    
}
