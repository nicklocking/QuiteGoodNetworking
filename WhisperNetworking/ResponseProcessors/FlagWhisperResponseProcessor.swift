class FlagWhisperResponseProcessor: CoreDataResponseProcessor {
    
    var wid: String
    
    required init(wid: String) {
        self.wid = wid
        super.init()
    }
    
    @available(*, deprecated: 1.0, message: "init not implemented; causes fatalError")
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func processWithLocalContext(_ localContext: NSManagedObjectContext) {
        Whisper.mr_deleteAll(matching: NSPredicate(format: "id = %@", wid), in: localContext)
    }
    
}
