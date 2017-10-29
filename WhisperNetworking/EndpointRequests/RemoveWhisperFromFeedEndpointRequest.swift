import Foundation

class RemoveWhisperFromFeedEndpointRequest: EndpointRequest {
    
    let feedID: String
    let wid: String
    
    required init(feedID: String, wid: String, banAuthor: Bool = false) {
        self.feedID = feedID
        self.wid = wid
        super.init()
        
        httpMethod = .post
        path = "/feeds/remove"
        requiresAuthenticatedUser = true
        
        let banAuthorString = (banAuthor ? "true" : "false")
        
        extraParameters = [
            "feed_id": feedID,
            "wid": wid,
            "remove_user": banAuthorString
        ]
        
        failureHTTPCodeToMessage = [
            403: NSLocalizedString("Sorry, you need to be the founder of a group to remove a whisper from it.", comment: "")
        ]
        defaultFailureMessage = NSLocalizedString("Sorry, we couldn't remove that whisper from the group.", comment: "")
    }
    
    override func createResponseProcessor() {
        responseProcessor = RemoveWhisperFromFeedResponseProcessor(feedID: feedID, wid: wid)
    }
    
    override func didCompleteRequestSuccessfully() {
        
        super.didCompleteRequestSuccessfully()
        
        var feedName: String? = nil
        MagicalRecord.save( blockAndWait: { (context) in
            guard let feed = Feed.mr_findFirst(byAttribute: Feed.idKey, withValue: self.feedID, in: context) else {
                return
            }
            feedName = feed.name
        })
        
        TrackingEvent(name: "Whisper Removed from Group", standardProperties: [
            "source_feed_name": feedName,
            "source_feed_id": feedID,
            "wid": wid
            ])
            .submit()
    }
    
    override func didFailRequest() {
        if let code = httpStatusCode,
        let errors = errorJSON?["errors"].arrayObject as? [String]
        , code == 403 && errors.contains("feed_not_in_whisper") {
            failureHTTPCodeToMessage[403] = NSLocalizedString("This whisper is no longer in the group.", comment: "")
        }
        super.didFailRequest()
    }
}
