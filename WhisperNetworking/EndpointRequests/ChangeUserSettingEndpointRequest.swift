@objc enum SettingType: Int {
    case gender, preferredGender, ifa, locale, systemLocale, age, promptForSchool, showMeEverything, nearbyChat, pushReply, pushHeart, pushGeo, pushRelated, pushDaily
    
    func name() -> String {
        switch self {
        case .gender:
            return "gender"
        case .preferredGender:
            return "interested_in"
        case .ifa:
            return "ifa"
        case .locale:
            return "locale"
        case .systemLocale:
            return "system_locale"
        case .age:
            return "age"
        case .promptForSchool:
            return "prompt_for_school"
        case .showMeEverything:
            return "sme"
        case .nearbyChat:
            return "only_nearby_conversations"
        case .pushGeo:
            return "push_geo"
        case .pushDaily:
            return "push_wotd"
        case .pushHeart:
            return "push_heart"
        case .pushRelated:
            return "push_comment_reply"
        case .pushReply:
            return "push_reply"
        }
    }
}

class ChangeUserSettingEndpointRequest: EndpointRequest {
    
    static let userSettingsUpdatedNotificationName = "user_settings_updated"
    static let userAgeOrGenderUpdatedNotificationName = "remote_gender_or_age_changed_notification"
    
    var setting: Int
    var value: NetworkParameter

    @objc convenience init(setting: Int, value: AnyObject) {
        self.init(setting: setting, encodableValue: value as! NetworkParameter)
    }
    
    required init(setting: Int, encodableValue: NetworkParameter) {
        
        self.setting = setting
        self.value = encodableValue
        
        super.init()
        
        requiresAuthenticatedUser = true
        path = "/user/settings"
        httpMethod = .post
        
        extraParameters = [
            "type": SettingType(rawValue: setting)?.name(),
            "value": value
        ]
    }
        
    override func didCompleteRequestSuccessfully() {
        super.didCompleteRequestSuccessfully()
        NotificationCenter.default.post(name: Notification.Name(rawValue: ChangeUserSettingEndpointRequest.userSettingsUpdatedNotificationName), object: nil)
        guard let settingType = SettingType(rawValue: setting) else {
            return
        }
        if settingType == .age || settingType == .gender {
            if let valueString = value as? String , settingType == .gender {
                WTracker.shared().trackChatSettingsGenderChanged(valueString)
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: ChangeUserSettingEndpointRequest.userAgeOrGenderUpdatedNotificationName), object: nil)
        }
        if let valueString = value as? String , settingType == .preferredGender {
            WTracker.shared().trackChatSettingsPreferredGenderChanged(valueString)
        }
        if let valueString = value as? String , settingType == .nearbyChat {
            WTracker.shared().trackChatSettingsNearbyEnabled(valueString == "true")
        }
        if let valueString = value as? String , settingType == .showMeEverything {
            WTracker.shared().trackMeHideNSFWEnabledChange(valueString != "true")
        }
        if let valueString = value as? String , isPushSetting() {
            WTracker.shared().trackSettingsPushType(PushTypeToSettingTypeConverter.convertSettingTypeToPushType(settingType), enabled: valueString == "true")
        }
    }
    
    func isPushSetting() -> Bool {
        guard let settingType = SettingType(rawValue: setting) else {
            return false
        }
        return settingType == .pushRelated || settingType == .pushDaily || settingType == .pushHeart || settingType == .pushGeo || settingType == .pushReply
    }
}
