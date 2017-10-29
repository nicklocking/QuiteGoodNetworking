class FetchGiphyResponseProcessor: ResponseProcessor {
    
    var giphyResultURLs = [String]()
    var giphyResultSizes = [NSValue]()
    
    override func process() {
        
        guard let responseDictionary = responseDictionary(),
        let metaArray = responseDictionary["data"] as? [NetworkDictionary] , metaArray.count > 0 else {
            return
        }
        
        for giphyData in metaArray {
            guard
                let imagesData = giphyData["images"] as? NetworkDictionary,
                let imageData = imagesData["fixed_height"] as? NetworkDictionary,
                let imageURL = imageData["url"] as? String,
                let width = imageData["width"] as? NSString,
                let height = imageData["height"] as? NSString else
            {
                continue
            }
            giphyResultURLs.append(imageURL)
            giphyResultSizes.append(NSValue(cgSize: CGSize(width: CGFloat(width.doubleValue), height: CGFloat(height.doubleValue))))
        }
    }
    
}
