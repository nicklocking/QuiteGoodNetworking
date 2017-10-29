class FetchNewUserChallengeResponseProcessor: ResponseProcessor {
    
    var foundHash: String?
    var challengeToken: String?
    
    override func process() {
        
        guard let responseDictionary = responseDictionary(),
        let challengeToken = responseDictionary["token"] as? String,
        let challengeZeroesNumber = responseDictionary["expected"] as? NSNumber else {
            return
        }
        
        foundHash = WSecurity.findHashValue(withToken: challengeToken, zeroes: Int32(challengeZeroesNumber.intValue))
        self.challengeToken = challengeToken
    }
    
}
