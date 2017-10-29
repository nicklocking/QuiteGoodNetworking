class FetchWhisperMediaResponseProcessor: CoreDataResponseProcessor {
    
    let searchTerm: String?
    var scrollID: String?
    
    required init(searchTerm: String?) {
        self.searchTerm = searchTerm
        
        super.init()
    }
    
    @available(*, deprecated: 1.0, message: "init not implemented; causes fatalError")
    required init() {
        fatalError("init() has not been implemented")
    }

    override func processWithLocalContext(_ localContext: NSManagedObjectContext) {
        guard let dictionary = responseDictionary(), let mediaArray = dictionary["media"] as? [NetworkDictionary] else {
            return
        }
        
        if let localScrollID = dictionary["scroll_id"] as? String {
            scrollID = localScrollID
        }
        
        for mediaDictionary in mediaArray {
            let createMedia = CreateMedia.mr_createEntity(in: localContext)
            createMedia?.setValuesForKeysWithJSONDictionary(mediaDictionary)
            createMedia?.searchTerm = searchTerm
            if let _ = searchTerm {
                createMedia?.sourceNumber = MediaSource.search.rawValue as NSNumber?
            } else {
                createMedia?.sourceNumber = MediaSource.suggest.rawValue as NSNumber?
            }
            
            if let imageURLString = createMedia?.imageURLString, let imageURL = URL(string: imageURLString) {
                system().imageCache.imageDownloader.downloadImage(imageURL)
            }
        }
    }
    
}
