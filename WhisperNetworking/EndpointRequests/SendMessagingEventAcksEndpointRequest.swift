class SendMessagingEventAcksEndpointRequest: MessagingEndpointRequest {
    
    var eventIDs: [String]
    
    required init(eventIDs: [String]) {
        
        self.eventIDs = eventIDs
        
        super.init()
        
        httpMethod = .post
        
        path = "/v1/events/ack"
    
        errorTrackingProperties = ["First Launch":WTracker.shared().isFirstLaunch(),
                                   "Total Launches":WTracker.shared().totalLaunches(),
                                   "Event Count":eventIDs.count]
    }
    
    override func parameters() -> NetworkDictionary {
        return super.parameters() + ["events":eventIDs.joined(separator: ",")]
    }
    
    override func headers() -> [String : String] {
        return super.headers()
    }
}
