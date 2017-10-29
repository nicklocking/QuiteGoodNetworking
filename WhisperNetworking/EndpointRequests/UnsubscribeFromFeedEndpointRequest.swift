import Foundation

class UnsubscribeFromFeedEndpointRequest: EndpointRequest {

    var feedID: String
    var source: String?
    
    required init(feedID: String, source: String?) {
        
        self.feedID = feedID
        self.source = source
        
        super.init()
        
        path = "/feeds/unsubscribe"
        
        requiresAuthenticatedUser = true
        
        defaultFailureMessage = NSLocalizedString("Oops, we couldn't unsubscribe to this feed.", comment: "")
        
        httpMethod = .post
        
        extraParameters = ["feed_id":feedID]
    }
    
    override func createResponseProcessor() {
        responseProcessor = UnsubscribeFromFeedResponseProcessor.init(feedID: feedID, source: source)
    }

}
