class FetchShortURLForWIDResponseProcessor: ResponseProcessor {
    
    var wid: String
    
    required init(wid: String) {
        self.wid = wid
        super.init()
    }
    
    @available(*, deprecated: 1.0, message: "FetchShortURLForWIDResponseProcessor has not implemented init, causes fatalError")
    required init() {
        fatalError("init() has not been implemented")
    }

    override func process() {
        
        super.process()
        
        if let shortURL = responseDictionary()?["short_url"] as? String
        {
            NotificationCenter.default.postNotificationOnMainThread(FetchShortURLForWIDResponseProcessor.shortURLAvailableNotificationName(wid), object: nil, userInfo: [WUserInfoStringKey:shortURL])
        }
    }
    
    class func shortURLAvailableNotificationName(_ wid: String) -> NSNotification.Name {
        return NSNotification.Name(wid + "_surl")
    }
}
