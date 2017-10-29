class DeleteConversationsEndpointRequest: EndpointRequest {
    
    var reason: String?
    var cids: [String]
    
    required init(action: String, reason: String?, cids: [String]) {
        self.reason = reason
        self.cids = cids
        
        super.init()
        
        requiresAuthenticatedUser = true
        
        responseProcessorType = DeleteConversationsResponseProcessor.self
        
        path = "/messaging/conversations/delete"
        
        httpMethod = .post
        
        errorTrackingProperties = ["conversation_count": cids.count, "First Launch": WTracker.shared().isFirstLaunch(), "Total Launches": WTracker.shared().totalLaunches()]
        
        extraParameters = [
            "cids": cids.joined(separator: ","),
            "action": action,
            "reason": reason
        ]
    }
    
    override func didFailRequest() {
        super.didFailRequest()
        
        WTracker.shared().trackMessagingConversationsDeletedFailed(UInt(cids.count), reason: reason)
        
        var message: String
        if cids.count > 1 {
            message = NSLocalizedString("There was some trouble deleting your conversations. Try again soon!", comment: "")
        } else {
            message = NSLocalizedString("There was some trouble deleting your conversation. Try again soon!", comment: "")
        }
        
        let alertController = UIAlertController(title: NSLocalizedString("Oh Nos!", comment: ""), message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        WAppDelegate.shared().baseNavigationController()?.present(alertController, animated: true, completion: nil)
    }
    
    override func createResponseProcessor() {
        super.createResponseProcessor()
        if let deleteConversationsResponseProcessor = responseProcessor as? DeleteConversationsResponseProcessor {
            deleteConversationsResponseProcessor.cids = cids
            // isBan only if reason is not nil
            deleteConversationsResponseProcessor.isBan = reason != nil
        }
    }
}
