import Foundation

class TribeInvitationEndpointRequest: EndpointRequest {
    
    convenience init(shortFeedID: String) {
        self.init(shortFeedID: shortFeedID, feedID: nil)
    }
    
    convenience init(feedID: String) {
        self.init(shortFeedID: nil, feedID: feedID)
    }
    
    required init(shortFeedID: String?, feedID: String?) {
        
        super.init()
        
        httpMethod = .post
        
        path = "/feeds/invitation"
        
        requiresAuthenticatedUser = true
        
        extraParameters = [
            "uid": system().user?.uid,
            "feed_id": feedID,
            "short_feed_id": shortFeedID
        ]
        
        responseProcessorType = FetchInvitedFeedResponseProcessor.self
    }

}
