class FetchSuggestedLocationsResponseProcessor: CoreDataResponseProcessor {

    
    override func processWithLocalContext(_ localContext: NSManagedObjectContext) {
        
        LocationTaggerFeed.mr_deleteAll(matching: NSPredicate(format: "TRUEPREDICATE"), in: localContext)
        LocationTaggerSection.mr_deleteAll(matching: NSPredicate(format: "TRUEPREDICATE"), in: localContext)
        
        guard let responseDictionary = self.responseDictionary(),
            let sectionDictionaries = responseDictionary["sections"] as? [NetworkDictionary] else {
                return
        }
        
        for sectionDictionary in sectionDictionaries {
            
            guard let locationTaggerSection = LocationTaggerSection.mr_createEntity(in: localContext) else {
                continue
            }
            locationTaggerSection.setValuesForKeysWithJSONDictionary(sectionDictionary)
            
            guard let feedDictionaries = sectionDictionary["items"] as? [NetworkDictionary] else {
                continue
            }
            
            for feedDictionary in feedDictionaries {
                guard let locationTaggerFeed = LocationTaggerFeed.mr_createEntity(in: localContext) else {
                    continue
                }
                
                locationTaggerFeed.setValuesForKeysWithJSONDictionary(feedDictionary)
                locationTaggerSection.addLocationTaggerFeedsObject(locationTaggerFeed)
            }
        }

    }
    
}
