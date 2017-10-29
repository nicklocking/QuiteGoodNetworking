class PostNewUserResponseProcessor: ResponseProcessor {
    
    var uid: String?
    var pin: String?
    
    override func process() {
        
        guard let responseDictionary = responseDictionary() else {
            return
        }
        
        if let uid = responseDictionary["uid"] as? String {
            self.uid = uid
        }
        
        if let pin = responseDictionary["pin"] as? String {
            self.pin = pin
        }

    }
    
}
