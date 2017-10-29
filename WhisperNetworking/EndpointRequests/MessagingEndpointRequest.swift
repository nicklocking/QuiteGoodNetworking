class MessagingEndpointRequest: EndpointRequest {
    
    override var baseURLString: String { get { return "https://whisper.api.tigertext.me" } }
    
    override func headers() -> [String : String] {
        return MessagingEndpointRequestHeaders.headers()
    }
    
}