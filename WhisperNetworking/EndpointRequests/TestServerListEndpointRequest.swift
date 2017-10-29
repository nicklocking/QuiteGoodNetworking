class TestServerListEndpointRequest: EndpointRequest {
    
    override var baseURLString: String { get { return "https://s3-us-west-2.amazonaws.com" } }
    
    required override init() {
    
        super.init()
        
        path = "/whisper-header-list/header_list.json"
        
        responseProcessorType = TestServerListResponseProcessor.self
    }
}
