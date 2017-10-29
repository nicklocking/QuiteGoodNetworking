/**
 * Used if we get a message from a conversation we didn't see in FetchConversationListEndpointRequest.
 * That endpoint only gets the 100 most recent conversations.
 */
class FetchConversationEndpointRequest: EndpointRequest {
    
    let groupToken: String
    let duringReplay: Bool
    
    required init(groupToken:String, duringReplay:Bool) {
        self.groupToken = groupToken
        self.duringReplay = duringReplay
        
        super.init()
        
        requiresAuthenticatedUser = true
        
        path = "/messaging/conversation/by_group/\(groupToken)"
        
        responseProcessorType = FetchConversationListResponseProcessor.self
        
        errorTrackingProperties = ["First Launch":WTracker.shared().isFirstLaunch(),
                                   "Total Launches":WTracker.shared().totalLaunches(),
                                   "Group Token":groupToken]
    }
    
    override func createResponseProcessor() {
        super.createResponseProcessor()
        
        if let localResponseProcessor = responseProcessor as? FetchConversationListResponseProcessor {
            localResponseProcessor.groupToken = groupToken
            localResponseProcessor.duringReplay = duringReplay
        }
    }
}
