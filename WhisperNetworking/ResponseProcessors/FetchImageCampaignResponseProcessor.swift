import Foundation

class FetchImageCampaignResponseProcessor: CoreDataResponseProcessor {
    
    // This is actually the campaign ad insertion probability, but having consistency with server variable names
    static let imageCampaignReplacementRatioKey = "image_campaign_replacement_ratio"
    static let imageCampaignActiveStatusKey = "image_campaign_active_status"
    static let imageCampaignListOfWidsKey = "image_campaign_list_of_wids"
    
    static let whispersKey = "whispers"
    static let whisperIDKey = "wid"
    static let replacementRatioKey = "replacement_ratio"
    static let activeKey = "active"
    
    override func processWithLocalContext(_ localContext: NSManagedObjectContext) {
        
        guard let dictionary = responseDictionary() else {
            return
        }
        
        guard let listOfWhispers = dictionary[FetchImageCampaignResponseProcessor.whispersKey] else {
            return
        }
        
        if let replacementRatio = dictionary[FetchImageCampaignResponseProcessor.replacementRatioKey] as? Double {
            UserDefaults.standard.set(replacementRatio, forKey: FetchImageCampaignResponseProcessor.imageCampaignReplacementRatioKey)
        }
        
        if let activeStatus = dictionary[FetchImageCampaignResponseProcessor.activeKey] as? Bool {
            UserDefaults.standard.set(activeStatus, forKey: FetchImageCampaignResponseProcessor.imageCampaignActiveStatusKey)
        }
        
        var listOfWIDsForCampaign = [String]()
        
        for whisperDictionary in listOfWhispers as! [NetworkDictionary] {
            
            guard let user = system().user , user.shouldAddWhisper(whisperDictionary) else {
                continue
            }
            
            guard let whisperID = whisperDictionary[FetchImageCampaignResponseProcessor.whisperIDKey] as? String else {
                continue
            }
            
            let whisper = Whisper.mr_findFirstOrCreate(byAttribute: FeedItem.idKey, withValue: whisperID, in: localContext)
            whisper.setValuesForKeysWithJSONDictionary(whisperDictionary, keyPrefix: "")
            
            listOfWIDsForCampaign.append(whisperID)
        }
        
        UserDefaults.standard.set(listOfWIDsForCampaign, forKey: FetchImageCampaignResponseProcessor.imageCampaignListOfWidsKey)
        
        
    }
    
}
