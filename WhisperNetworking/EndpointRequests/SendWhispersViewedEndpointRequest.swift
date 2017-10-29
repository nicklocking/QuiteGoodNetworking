import Alamofire
import SwiftyJSON

class SendWhispersViewedEndpointRequest: EndpointRequest {
    
    required init?(whispersViewed: [NetworkOptionalsDictionary]) {
        
        super.init()
        
        do {
            guard let convertedViewData = whispersViewed.makeArrayNetworkEncodable() else {
                return nil
            }
            httpBodyData = try JSON(arrayLiteral: convertedViewData).rawData(options: JSONSerialization.WritingOptions(rawValue: 0))
        } catch {
            assertionFailure("JSON encoding error: \(error)")
            return nil
        }
        
        requiresAuthenticatedUser = true
        
        httpMethod = .post
        
        encodingMethod = JSONEncoding.default
        
        guard let uid = system().user?.uid else {
            assertionFailure("Error: Cannot send whispers viewed without a uid")
            return nil
        }
        
        path = "/whispers/viewed/\(uid)"
    }
    
}
