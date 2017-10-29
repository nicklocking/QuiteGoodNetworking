import Foundation

class UnsubscribeFromFeedResponseProcessor: CoreDataResponseProcessor {
    
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
        
        let feed = TribeFeed.mr_findFirstOrCreate(byAttribute: Feed.idKey, withValue: feedID, in: localContext)
        feed.unsubscribedTimestamp = Date()
        feed.locked = false
        feed.invited = false
        
        // A TribeSearchFeed is kept separate from the actual TribeFeed, so update any existing search feed
        if let searchFeed = TribeSearchFeed.mr_findFirst(byAttribute: TribeSearchFeed.idKey, withValue: feedID, in: localContext) {
            searchFeed.unsubscribedTimestamp = feed.unsubscribedTimestamp
        }
        
        var properties = NetworkOptionalsDictionary()
        var isUserFounder = false
        
        properties["feed_name"] = feed.serverName
        properties["type"] = feed.tribeType.name()
            
        if let localFeed = TribeFeed.mr_findFirst(with: NSPredicate(format: "id = %@", feedID), in: localContext) , localFeed.isUserFounder() {
            isUserFounder = true
        }
        
        properties +=  [
            "feed_id": feedID,
            "source": source,
            "object_id": isUserFounder ? "founder" : "member",
            "object_type": "role"
        ]
        
        TrackingEvent(name: "Feed Unsubscribed", standardProperties: properties).submit()
    }
    
    override func performAfterSave() {
        system().endpointRequestOperationQueue.addOperation(FetchUserSettingsEndpointRequest())
    }
}
