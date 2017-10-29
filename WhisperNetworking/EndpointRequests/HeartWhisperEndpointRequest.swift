class HeartWhisperEndpointRequest: EndpointRequest {

    var wid: String
    var recommender: String?
    var feedID: String?
    var feedType: String?
    var feedName: String?
    
    required init(wid: String, recommender: String?, feedID: String?, feedType: String?, feedName: String?) {
        self.wid = wid
        self.recommender = recommender
        self.feedID = feedID
        if feedType == "my_hearts" {
            self.feedType = "other"
        } else {
            self.feedType = feedType
        }
        self.feedName = feedName
        
        super.init()
        
        path = "/whisper/me2"
        httpMethod = .post
        requiresAuthenticatedUser = true
        
        extraParameters = [
            "wid":self.wid,
            "recommender":self.recommender,
            "feed_id":self.feedID,
            "feed_type":self.feedType,
            "origin":self.feedType
        ]
    }
    
    override func didCompleteRequestSuccessfully() {
        super.didCompleteRequestSuccessfully()
        WTracker.shared().trackBrowserHeart(withWhisperID: self.wid, feedID: feedID ?? "", feedName: feedName ?? "");
    }
    
}
