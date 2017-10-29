import Foundation

class SubscribeToFeedEndpointRequest: EndpointRequest {
    
    var feedID: String
    var source: String?
    var onCampus: Bool
    
    required init(feedID: String, source: String?, onCampus: Bool = false) {
        
        self.feedID = feedID
        self.source = source
        self.onCampus = onCampus
        
        super.init()
        
        path = "/feeds/subscribe"
        
        requiresAuthenticatedUser = true
        
        defaultFailureMessage = NSLocalizedString("Oops, we couldn't subscribe to this feed.", comment: "")

        failureHTTPCodeToMessage += [
            403: "You could not be added to this group at this time."
        ]
        
        httpMethod = .post
        
        responseProcessorType = SubscribeToFeedResponseProcessor.self
        
        if onCampus {
            extraParameters = ["type":"on_campus"]
        }
    }
    
    override func parameters() -> NetworkDictionary {
        return super.parameters() + ["feed_id":feedID]
    }
    
    override func createResponseProcessor() {
        if onCampus {
            //We don't need to proccess a response if we are performing an on campus subscription
            return
        }
        responseProcessor = SubscribeToFeedResponseProcessor.init(feedID: feedID, source: source)
    }
}
