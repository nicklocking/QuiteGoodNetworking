import Foundation
import Alamofire

class CreateFeedEndpointRequest: EndpointRequest {
    
    required init(name: String, type: FeedType, description: String?, imageURL: URL?, imageSource: String?, cropRect: CGRect?) {
        
        super.init()
        
        assert(imageSource == nil || imageSource == "none" || imageURL?.absoluteString != nil, "imageSource must be nil or 'none' if the imageURL is nil")
        
        httpMethod = .post
        
        encodingMethod = JSONEncoding.default
        
        path = "/feeds/create"
        
        responseProcessorType = EditFeedResponseProcessor.self
        
        requiresAuthenticatedUser = true
        
        defaultFailureMessage = NSLocalizedString("Oops, we couldn't create this group.", comment: "")
        
        failureHTTPCodeToMessage = [
            400: NSLocalizedString("There's a problem with the way we're trying to talk to the server.  It's not your fault.  Please leave this screen and try again.", comment: ""),
            403: NSLocalizedString("Please use a cleaner name and description and try again.", comment: ""),
            404: NSLocalizedString("We couldn't find your user. Try force-quitting the app and restarting.", comment: ""),
            409: NSLocalizedString("A group with the same name already exists.", comment: ""),
            429: NSLocalizedString("You've been trying to create a lot of groups.  Please wait a while before trying again.", comment: "")
        ]
        
        extraParameters = ["type": type.name(),
                           "name": name,
                           "description": description,
                           "image_url": imageURL?.absoluteString,
                           "image_source": imageSource ?? "none"
        ]
        
        if var rect = cropRect {
            // The API requires these parameters to be Int, not Float
            rect = rect.integral
            
            let cropParams: NetworkOptionalsDictionary = [
                "crop_offset_x": rect.origin.x,
                "crop_offset_y": rect.origin.y,
                "crop_width": rect.size.width,
                "crop_height": rect.size.height
                ]
            
            extraParameters? += cropParams
        }
    }
}
