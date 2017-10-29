import Foundation
import Alamofire

class EditFeedEndpointRequest: EndpointRequest {
    
    required init(feedID: String, name: String, description: String?) {
        
        super.init()
        
        httpMethod = .post
        
        encodingMethod = JSONEncoding.default
        
        path = "/feeds/update"
        
        responseProcessorType = EditFeedResponseProcessor.self
        
        defaultFailureMessage = NSLocalizedString("Oops, we couldn't save your changes.", comment: "")
        
        requiresAuthenticatedUser = true
        
        failureHTTPCodeToMessage = [
            400: NSLocalizedString("There's a problem with the way we're trying to talk to the server.  It's not your fault.  Please leave this screen and try again.", comment: ""),
            403: NSLocalizedString("Please use a cleaner name and description and try again.", comment: ""),
            404: NSLocalizedString("We couldn't find your user. Try force-quitting the app and restarting.", comment: ""),
            409: NSLocalizedString("A group with the same name already exists.", comment: ""),
            429: NSLocalizedString("You've been trying to edit a lot of groups.  Please wait a while before trying again.", comment: "")
        ]
        
        extraParameters = ["feed_id": feedID,
                           "name": name,
                           "description": description
        ]
    }
}
