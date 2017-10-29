import Alamofire

class FeedInviteAnonymousEndpointRequest: EndpointRequest {
    
    var sanitizedNumberToOriginal = [String: String]()
    
    required init?(feedID: String, numbers: [String]) {
        guard numbers.count > 0 else {
            assertionFailure()
            return nil
        }
        super.init()
        
        failureHTTPCodeToMessage = [
            400: NSLocalizedString("Sorry, we couldn't find that group.", comment: ""),
            429: NSLocalizedString("You've sent a lot of invites! Please wait a while before sending any more.", comment: "")
        ]
        
        path = "/feeds/anonymous_invite"
        
        httpMethod = .post
        encodingMethod = JSONEncoding.default
        
        requiresAuthenticatedUser = true
        
        /// This needs to change once the server's formatting system is updated
        let validCharacters = "0123456789+".characters
        numbers.forEach {
            let sanitized = String( $0.characters.filter( {validCharacters.contains($0)}) )
            sanitizedNumberToOriginal[sanitized] = $0
        }
        
        extraParameters = [
            "feed_id": feedID,
            "phone_numbers": Array(sanitizedNumberToOriginal.keys)
        ]
    }
}
