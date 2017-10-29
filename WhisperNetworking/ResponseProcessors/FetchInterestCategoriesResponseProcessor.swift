class FetchInterestCategoriesResponseProcessor: ResponseProcessor {
    
    var interestsArray = [Interest]()
    
    override func process() {
        
        if let responseDictionary = responseDictionary(),
        let interestDictionaries = responseDictionary["feeds"] as? [NetworkDictionary] {
            for interestDictionary in interestDictionaries {
                if let name = interestDictionary["name"] as? String,
                let displayName = interestDictionary["displayname"] as? String,
                let interestID = interestDictionary["id"] as? String,
                let preSelected = interestDictionary["selected"] as? Bool {
                    interestsArray.append(Interest(name: name, displayName: displayName, id: interestID, selected: preSelected))
                }
                
            }
        }
    }
}
