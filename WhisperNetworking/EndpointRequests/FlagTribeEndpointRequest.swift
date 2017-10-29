import Foundation

class FlagTribeEndpointRequest: EndpointRequest {
    
    var feedID: String
    
    required init(feedID: String) {
        self.feedID = feedID
        
        super.init()
        
        httpMethod = .post
        
        defaultFailureMessage = NSLocalizedString("Oops, we couldn't flag this group.", comment: "")
        
        path = "/feeds/flag"
        
        requiresAuthenticatedUser = true
        
        extraParameters = [
            "uid": system().user?.uid,
            "feed_id": feedID
        ]
    }
    
}
