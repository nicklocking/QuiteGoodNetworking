class FetchSettingsForUserResponseProcessor: ResponseProcessor {
    
    override func process() {
        
        if let responseDictionary = responseDictionary() {
            system().user?.update(with: responseDictionary)
        }
        
    }
    
}
