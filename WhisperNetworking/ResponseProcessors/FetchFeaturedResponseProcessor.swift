import Foundation

class FetchFeaturedTribesResponseProcessor: CoreDataResponseProcessor {
    
    override func processWithLocalContext(_ localContext: NSManagedObjectContext) {
        
        guard let dictionary = responseDictionary() else {
            return
        }
        
        guard let featuredTribes = dictionary["feeds"] as? [NetworkDictionary] else {
            return
        }
        
        if let goalUserCount = dictionary["goal_user_count"] as? NSInteger {
            UserDefaults.standard.set(goalUserCount, forKey: TribeFeed.goalUserCountKey)
        }
        
        let feedIDs = featuredTribes.flatMap({ $0[TribeFeed.idKey] })
        guard feedIDs.count > 0 else {
            return
        }
        
        TribeFeed.mr_deleteAll(matching: NSPredicate(format: "NOT (id IN %@) && discoverFeatured = true", argumentArray: [feedIDs]), in: localContext)
        
        for var featuredTribeDictionary in featuredTribes {
            
            guard let feedID = featuredTribeDictionary[TribeFeed.idKey] as? String else {
                continue
            }
            
            if let user = system().user , !user.shouldAddTribe(feedID) {
                continue
            }
            
            // We do this as we want to have two different sort values for the featured feeds in Tribes at the HomeFeed and discover table view
            let discoverFeaturedSortValue = featuredTribeDictionary.removeValue(forKey: "sort")
            featuredTribeDictionary["discoverFeaturedSort"] = discoverFeaturedSortValue
            
            let featuredFeed = TribeFeed.mr_findFirstOrCreate(byAttribute: TribeFeed.idKey, withValue: feedID, in: localContext)
            featuredFeed.setValuesForKeysWithJSONDictionary(featuredTribeDictionary)
            featuredFeed.discoverFeatured = true
            
        }
        
    }
    
}
