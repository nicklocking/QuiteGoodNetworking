/**
 * Fetches the 100 most recent conversations
 */
class FetchConversationListEndpointRequest: EndpointRequest {
    
    required override init() {
        
        super.init()
        
        requiresAuthenticatedUser = true
        
        path = "/messaging/conversations_v2"
        
        responseProcessorType = FetchConversationListResponseProcessor.self
        
        errorTrackingProperties = ["First Launch": WTracker.shared().isFirstLaunch(), "Total Launches": WTracker.shared().totalLaunches()]
    }
    
    override func didCompleteRequestSuccessfully() {
        super.didCompleteRequestSuccessfully()
        
        if let responseETag = endpointRequest?.response?.allHeaderFields["ETag"] as? String {
            FetchConversationListEndpointRequest.setETag(responseETag)
        }
    }
    
    override func headers() -> [String : String] {
        if let eTag = FetchConversationListEndpointRequest.getETag() {
            return super.headers() + ["If-None-Match": eTag]
        }
        return super.headers()
    }
}
