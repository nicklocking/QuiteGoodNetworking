class FetchSettingsForUserEndpointRequest: EndpointRequest {
    
    override init() {
        super.init()
        
        guard let uid = system().user?.uid else {
            cancel()
            failure?(self)
            return
        }
        
        path = "/user/verify/\(uid)"
        
        requiresAuthenticatedUser = true
        
        responseProcessorType = FetchSettingsForUserResponseProcessor.self
    }
    
    override func didCompleteRequestSuccessfully() {
        
        if !WTracker.shared().isFirstLaunch() && !WTracker.shared().isFirstVersionLaunch() {
            WAppDelegate.shared().registerForRemoteNotifications()
            UserVerifyTracking(registeredForNotification: true).submit()
        }
        
        super.didCompleteRequestSuccessfully()
    }
    
}
