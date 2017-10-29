class FetchOwnChatRatingResponseProcessor: ResponseProcessor {
    
    var rating: CGFloat = 0.0
    var totalNumberOfRatings: Int = 0
    
    override func process() {
        
        if let responseDictionary = responseDictionary(),
        let rating = responseDictionary["average"] as? NSNumber,
        let totalNumberOfRatings = responseDictionary["total"] as? Int {
            self.rating = CGFloat(rating.floatValue)
            self.totalNumberOfRatings = totalNumberOfRatings
        }
        
    }
    
}