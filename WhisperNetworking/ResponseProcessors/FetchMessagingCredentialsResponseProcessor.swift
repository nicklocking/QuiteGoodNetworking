class FetchMessagingCredentialsResponseProcessor: ResponseProcessor {
    
    override func process() {
        
        super.process()
        
        guard let user = system().user, let responseDictionary = responseDictionary() else {
            return
        }
        
        if user.setMessagingCredentialsWith(responseDictionary) && user.ttKey != "deadbeef" && user.ttSecret != "deadbeef" {
            WRemote.shared().startMessagingEngine()
        }
    }
    
}
