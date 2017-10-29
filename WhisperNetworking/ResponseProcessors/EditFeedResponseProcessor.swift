import Foundation

/// Used for Create and Edit
class EditFeedResponseProcessor: CoreDataResponseProcessor {
    
    var feedID: String?
    var feedType: FeedType?
    
    /// If the request fails due to a conflict with an existing feed, the existing feed's ID will be here
    var preExistingFeedID: String?
    
    override func processWithLocalContext(_ localContext: NSManagedObjectContext) {
        
        guard errorJSON == nil else {
            return
        }
        guard let dictionary = responseDictionary()?["feed"] as? NetworkDictionary else {
            return
        }
        
        guard let id = dictionary["id"] as? String else {
            assert(false, "Created feed has no feedID")
            return
        }
        
        let feed = TribeFeed.mr_findFirstOrCreate(byAttribute: Feed.idKey, withValue: id, in: localContext)
        let existingSubscribedTimestamp = feed.subscribedTimestamp
        feed.setValuesForKeysWithJSONDictionary(dictionary, keyPrefix: "")
        
        /**
         * At the time of this writing, Platform passes down `subscribed_ts = 0` for feed edit and create endpoints.
         * Temporarily work around this by trying the existing timestamp or creating a new one.
         * Platform JIRA: SD-3184
         * -Clint Stevenson, 2016.05.23
         */
        feed.subscribedTimestamp = feed.subscribedTimestamp ?? existingSubscribedTimestamp ?? Date()
        
        feedID = feed.id
        feedType = feed.feedType
    }
    
    override func processErrorResponse() {
        
        guard let feedJSON = errorJSON?["feed"],
            let feedData = feedJSON.dictionary,
            let feedID = feedData[Feed.idKey]?.stringValue,
            let feedTypeName = feedData["feed_type"]?.stringValue,
            let feedRawDictionary = feedJSON.dictionaryObject as? NetworkDictionary else
        {
            // setValuesForKeysWithDictionary needs NetworkDictionary
            return
        }
        
        let feedType = FeedType.feedTypeForName( feedTypeName )
        
        MagicalRecord.save(blockAndWait: { (context) in
            let existingFeed = feedType.feedCreationType().mr_findFirstOrCreate(byAttribute: TribeFeed.idKey, withValue: feedID, in: context)
            existingFeed.setValuesForKeysWithJSONDictionary(feedRawDictionary, keyPrefix: "")
            
            self.preExistingFeedID = existingFeed.id
        })
    }
}
