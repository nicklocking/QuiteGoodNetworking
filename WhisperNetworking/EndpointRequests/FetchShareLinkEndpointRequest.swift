import Foundation

@objc enum ShareLinkType: Int {
    case invite
    
    func linkTypeName() -> String {
        switch self {
        case .invite: return "invite"
        }
    }
}

class FetchShareLinkEndpointRequest: EndpointRequest {
    
    var feedID: String?
    var type: String?
    var linkType: String?
    var shareService: String?
    
    required init(feedID: String, linkType: ShareLinkType, shareService: ShareService) {
        
        self.feedID = feedID
        self.type = "feed"
        self.linkType = linkType.linkTypeName()
        self.shareService = shareService.name().lowercased()
        
        super.init()
        
        path = "/share/link"
        
        httpMethod = .get
        
        queryParams = ["id":self.feedID, "type":self.type, "link_type":self.linkType, "channel":self.shareService, "uid":system().user?.uid]
    }
    
}
