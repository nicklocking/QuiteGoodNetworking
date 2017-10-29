import Alamofire

class FetchDiscoverCategoriesEndpointRequest: EndpointRequest {
    
    required init?(junkParameter: Bool) {
        
        super.init()
        
        MagicalRecord.save(blockAndWait: { (localContext) in
            if DiscoverCategoryFeed.mr_findAll(in: localContext)?.count == 0 {
                FetchDiscoverCategoriesEndpointRequest.setETag(nil)
            }
        })
        
        guard let uid = system().user?.uid else {
            assertionFailure("Tried to fetch categories without a user")
            return nil
        }
        
        responseProcessorType = FetchDiscoverCategoriesResponseProcessor.self

        path = "/categories/" + uid
        
        extraParameters = ["origin": "discover"] + WLocationManager.shared().location?.dictionaryRepresentation().convertToNetworkDictionary()
    }
    
    override func headers() -> [String : String] {
        var headers = super.headers()
        guard let localETag = FetchDiscoverCategoriesEndpointRequest.getETag() else {
            return headers
        }
        headers["if-none-match"] = localETag
        return headers
    }
    
    override func handleResponse(_ response: DataResponse<Data>) {
        super.handleResponse(response)
        if let eTag = response.response?.allHeaderFields["ETag"] as? String {
            FetchDiscoverCategoriesEndpointRequest.setETag(eTag)
        }
    }
    
}
