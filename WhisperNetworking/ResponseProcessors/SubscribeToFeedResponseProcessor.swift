import Foundation

class SubscribeToFeedResponseProcessor: CoreDataResponseProcessor {
    
    let feedID: String
    let source: String?
    
    required init(feedID: String, source: String?) {
        
        self.feedID = feedID
        self.source = source
        
        super.init()
    }
    
    @available(*, deprecated: 1.0, message: "init not implemented; causes fatalError")
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func processWithLocalContext(_ localContext: NSManagedObjectContext) {
        
        guard
            let dictionary = responseDictionary(),
            let feedDictionary = dictionary["feed"] as? NetworkDictionary else
        {
            return
        }
        
        let feed = TribeFeed.mr_findFirstOrCreate(byAttribute: Feed.idKey, withValue: feedID, in: localContext)
        
        feed.setValuesForKeysWithJSONDictionary(feedDictionary, keyPrefix: "")
        
        /// Unfortunately at the time of this writing, this endpoint gives us a `sort` value of 0
        if let lastPost = feed.lastWhisperPostedTimestamp?.timeIntervalSince1970 , feed.sort.intValue == 0 {
            feed.sort = NSNumber(value: llround( lastPost * 1000) as Int64) // Server dates are in millisenconds
        }
        
        feed.invited = false
        feed.subscribedTimestamp = Date()
        feed.lastFetchedTimestamp = Date()
        
        // A TribeSearchFeed is kept separate from the actual TribeFeed, so update any existing search feed
        if let searchFeed = TribeSearchFeed.mr_findFirst(byAttribute: TribeSearchFeed.idKey, withValue: feedID, in: localContext) {
            searchFeed.subscribedTimestamp = feed.subscribedTimestamp
        }
        
        var trackingProperties = NetworkOptionalsDictionary()
        trackingProperties["feed_name"] = feed.name
        trackingProperties["feed_id"] = feed.id
        trackingProperties["source"] = source
        trackingProperties["type"] = feed.tribeType.name()
        TrackingEvent(name: "Feed Subscribed", standardProperties: trackingProperties).submit()
    }
    
    override func performAfterSave() {
        system().endpointRequestOperationQueue.addOperation(FetchWhispersForFeedEndpointRequest(feedID: feedID, feedType: .tribe, withThumbnails: false, reason: .none))        
        system().endpointRequestOperationQueue.addOperation(FetchUserSettingsEndpointRequest())
    }
}
