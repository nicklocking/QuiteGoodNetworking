import Foundation

class SearchFeedsResponseSubprocessor {
    
    let feedType: FeedType
    let feedDictionaries: [NetworkDictionary]
    let query: String
    
    required init(query: String, feedType: FeedType, feedDictionaries: [NetworkDictionary]) {
        self.feedType = feedType
        self.feedDictionaries = feedDictionaries
        self.query = query
    }
    
    
    func processWithLocalContext(_ localContext: NSManagedObjectContext) {
        
        guard let typeForSearchFeed = searchFeedType() else {
            return
        }
        
        typeForSearchFeed.mr_deleteAll(matching: NSPredicate(format: "query != %@", query), in: localContext)
        
        /*
         * The server currently doesn't send subscribed_ts in search, even if you are subscribed.
         * Keep track of the feedIDs we're subscribed to.
         * -Clint Stevenson, 2016.05.25
         */
        /// Maps feed ID to subscribedTimestamp
        var subscribeDates = [String: Date]()
        if let subscribedFeeds = TribeFeed.mr_findAll(with: TribeFeed.subscribedFeedsPredicate(), in: localContext) as? [TribeFeed] , feedType == .tribe {
            subscribedFeeds
                .filter({$0.subscribedTimestamp != nil})
                .forEach({
                    subscribeDates[ $0.id ] = $0.subscribedTimestamp as Date?
                })
        }
        
        var searchResults = [WSearchItem]()
        
        for var dictionary in feedDictionaries {
            guard let feedID = dictionary[Feed.idKey] as? String else {
                continue
            }
            guard let user = system().user , user.shouldAddTribe(feedID) else {
                continue
            }
            let searchFeed = typeForSearchFeed.mr_findFirstOrCreate(byAttribute: typeForSearchFeed.idKey, withValue: feedID, in: localContext)
            dictionary["query"] = query
            searchFeed.setValuesForKeysWithJSONDictionary(dictionary)
            
            // Search feeds don't currently include the subscribe date, so make one up
            if let tribeSearchFeed = searchFeed as? TribeSearchFeed,
                let date = subscribeDates[ tribeSearchFeed.id ]
                , tribeSearchFeed.subscribedTimestamp == nil {
                tribeSearchFeed.subscribedTimestamp = date
                searchResults.append(WSearchItem(locationFeed: tribeSearchFeed))
            } else if let placeSearchFeed = searchFeed as? PlaceSearchFeed {
                searchResults.append(WSearchItem(locationFeed: placeSearchFeed))
            }
        }
        
        var userInfo = NetworkDictionary()
        
        if (feedDictionaries.count > 0) {
            userInfo[WUserInfoBoolKey] = NSNumber(value: true as Bool)
            userInfo[WUserInfoArrayKey] = searchResults
        } else {
            userInfo[WUserInfoBoolKey] = NSNumber(value: false as Bool)
        }
        
        if feedType == .place {
            NotificationCenter.default.postNotificationOnMainThread(
                NSNotification.Name( WFeedManagerLocationSearchResultsNotificationName(query) ),
                object: nil,
                userInfo: userInfo)
        }
    }
    
    
    func searchFeedType() -> Feed.Type? {
        switch feedType {
        case .tribe: return TribeSearchFeed.self
        case .place: return PlaceSearchFeed.self
        default:
            assertionFailure("Search for unhandled feed type")
            return nil
        }
    }
    
}
