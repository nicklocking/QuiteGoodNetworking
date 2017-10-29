import Foundation

class FetchDiscoverFeaturedFeedsEndpointRequest: EndpointRequest {
    
    required override init() {
        
        super.init()
        
        path = "/featured"
        
        responseProcessorType = FetchFeaturedTribesResponseProcessor.self
        
    }
    
}