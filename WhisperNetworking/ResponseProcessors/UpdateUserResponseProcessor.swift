class UpdateUserResponseProcessor: CoreDataResponseProcessor {
    
    var updateLanguage = false
    var onlyFirstPage = false
    var isReinstall = false
    
    override func processWithLocalContext(_ localContext: NSManagedObjectContext) {
        
        DispatchQueue.main.async {
            if let responseDictionary = self.responseDictionary() {
                system().user?.update(with: responseDictionary)
            }
        }
        
        if responseStatusCode == .noContent {
            return
        }
        
        guard let responseDictionary = responseDictionary(),
        let notificationDictionaries = responseDictionary["notifications"] as? [NetworkDictionary],
            let user = system().user else {
                return
        }
        
        var newNotificationsExist = true
        
        // We check if the notification message should be localized, if it should we check if it the locale has changed and update all the notifications if it did change
        if updateLanguage && WhisperLocaleSettings().systemLocaleChangedSinceLastBackground() {
            newNotificationsExist = false
            if let newScrollID = responseDictionary["scroll_id"] as? String , newNotificationsExist && notificationDictionaries.count > 0 && !onlyFirstPage {
                system().endpointRequestOperationQueue.addOperation(UpdateUserEndpointRequest(scrollID: newScrollID, onlyFirstPage: onlyFirstPage, updateLanguage: updateLanguage, isReinstall: isReinstall))
            }
            return
        }
            
        let mostRecentNotificationDuringMigrationDate = UserDefaults.standard.object(forKey: CoreDataMigration.mostRecentNotificationUserDefaultkey) as? Date
        
        for notificationDictionary in notificationDictionaries {
            
            if !user.shouldAddWhisper(notificationDictionary) {
                continue
            }
            
            guard let wid = notificationDictionary["wid"] as? String, let type = notificationDictionary["push_type"] as? String else {
                continue
            }
            
            var wasReadBeforeMigration = false
            if let localMostRecentNotificationDuringMigrationDate = mostRecentNotificationDuringMigrationDate, let localNotificationTimeStamp = notificationDictionary["ts"] as? Double {
                wasReadBeforeMigration = (localMostRecentNotificationDuringMigrationDate as AnyObject).compare(Date(timeIntervalSince1970: localNotificationTimeStamp / 1000000)) != ComparisonResult.orderedAscending
            }
            
            let predicate = NSPredicate(format: "wid = %@ AND type = %@", wid, type)
            if let notification = WNotification.mr_findFirst(with: predicate, in: localContext) {
                
                WCore().update(notification, with: notificationDictionary)
                
            } else if let notification = WCore().addNotification(notificationDictionary, in: localContext) , isReinstall || wasReadBeforeMigration {
                notification.read = true
                notification.seen = true
            }
        }
        
        if let _ = mostRecentNotificationDuringMigrationDate {
            UserDefaults.standard.set(nil, forKey: CoreDataMigration.mostRecentNotificationUserDefaultkey)
        }
        
        if let newScrollID = responseDictionary["scroll_id"] as? String , newNotificationsExist && notificationDictionaries.count > 0 && !onlyFirstPage {
            system().endpointRequestOperationQueue.addOperation(UpdateUserEndpointRequest(scrollID: newScrollID, onlyFirstPage: onlyFirstPage, updateLanguage: updateLanguage, isReinstall: isReinstall))
        }
    }
}
