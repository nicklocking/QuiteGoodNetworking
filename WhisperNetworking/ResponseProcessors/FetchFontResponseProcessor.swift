class FetchFontResponseProcessor: CoreDataResponseProcessor {
    
    var urlLocalPathWithFileName: URL
    var fileName: String
    var fontDictionary: NetworkDictionary
    
    init?(fontDictionary: NetworkDictionary) {
        self.fontDictionary = fontDictionary
        
        guard
            let urlString = fontDictionary["url"] as? String,
            let url = URL(string:urlString) else
        {
            return nil
        }
        let fileName = url.lastPathComponent
        
        self.urlLocalPathWithFileName = FontDownloader.localPath(fileName)
        self.fileName = fileName
        
        super.init()
    }
    
    @available(*, deprecated: 1.0, message: "init not implemented; causes fatalError")
    required init() {
        fatalError("init() has not been implemented")
    }
    
    override func processWithLocalContext(_ localContext: NSManagedObjectContext) {
        guard let localResponseData = responseData else {
            return
        }
        
        let writeSuccess: Bool = ((try? localResponseData.write(to: URL(fileURLWithPath: urlLocalPathWithFileName.absoluteString), options: [.atomic])) != nil)
        
        if !writeSuccess {
            return
        }
        let font = Font.mr_findFirstOrCreate(byAttribute: Font.fileNameKey, withValue: fileName, in: localContext)
        font.setValuesForKeysWithJSONDictionary(self.fontDictionary, keyPrefix: "")
        font.fileName = fileName;
    }
    
}
