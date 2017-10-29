class FetchWhispersForFeedEndpointRequest: EndpointRequest {
    
    var feedID: String
    var feedType: FeedType
    var withThumbnails: Bool
    var reason: FeedFetchReason
    
    required init(feedID: String, feedType: FeedType, withThumbnails: Bool, reason: FeedFetchReason) {
        
        self.feedID = feedID
        self.feedType = feedType
        self.withThumbnails = withThumbnails
        self.reason = reason
        
        super.init()
        
    }
    
    override func main() {
        
        MagicalRecord.save(blockAndWait: { (localContext: NSManagedObjectContext) in
            
            let feedCreationType = FeedTypeConverter.feedCreationType(self.feedType)
            let feed = feedCreationType.mr_findFirstOrCreate(byAttribute: Feed.idKey, withValue: self.feedID, in: localContext)
            
            if self.reason != .scrollingIntoNewPage {
                feed.scrollID = nil
            }
            
            var params = feed.endpointParameters()
            
            if system().user?.isHideNSFWEnabled == true {
                params += ["sme":"false"]
            } else {
                params += ["sme":"true"]
            }
            
            params += ["refresh_reason":self.reason.name()]
            
            self.extraParameters = params
            
            self.path = "/\(feed.endpoint())"
        })
        
        super.main()
    }
    
    override func createResponseProcessor() {
        let localResponseProcessor = FetchWhispersForFeedResponseProcessor(feedID: feedID, feedType: feedType, statusCode: statusCode(), fetchReason: reason)
        localResponseProcessor.relatedFeedIncludingOriginalWhisperAndCard = feedType == .relatedIncludingOriginalWhisperAndCard
        
        responseProcessor = localResponseProcessor
    }
    
    override func canReplaceOperation(_ operation: Operation) -> Bool {
        if let localOperation = operation as? FetchWhispersForFeedEndpointRequest , localOperation.feedType == feedType {
            return true
        }
        return false
    }
}
