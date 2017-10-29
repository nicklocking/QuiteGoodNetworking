import Foundation

class FetchImageCampaign: EndpointRequest {
    
    required override init() {
        
        super.init()
        
        path = "/image_campaigns"
        
        responseProcessorType = FetchImageCampaignResponseProcessor.self
        
        requiresAuthenticatedUser = true
        
    }
    
}
