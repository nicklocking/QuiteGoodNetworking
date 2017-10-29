class RemoveWhisperFromFeedResponseProcessor: CoreDataResponseProcessor {
    
    let wid: String
    let feedID: String
    
    required init(feedID: String, wid: String) {
        self.feedID = feedID
        self.wid = wid
        super.init()
    }
    
    @available(*, deprecated: 1.0, message: "init not implemented; causes fatalError")
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func processWithLocalContext(_ localContext: NSManagedObjectContext) {
        
        guard let feed = Feed.mr_findFirst(byAttribute: Feed.idKey, withValue: feedID, in: localContext),
        let whisper = Whisper.mr_findFirst(byAttribute: Whisper.idKey, withValue: wid, in: localContext) else {
            return
        }
        FeedSort.removeFeedSortForFeed(feed, feedItem: whisper, context: localContext)
    }
    
}
