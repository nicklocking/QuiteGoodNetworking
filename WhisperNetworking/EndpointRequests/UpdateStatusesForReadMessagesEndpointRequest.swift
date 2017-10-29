class UpdateStatusesForReadMessagesEndpointRequest: MessagingEndpointRequest {
    
    var readMIDs: [String]
    var deliveredMIDs: [String]
    
    required init(readMIDs: [String], deliveredMIDs: [String]) {
        
        self.readMIDs = readMIDs
        self.deliveredMIDs = deliveredMIDs
        
        super.init()
        
        path = "/v1/message/status"
        
        httpMethod = .post
        
        errorTrackingProperties = ["First Launch":WTracker.shared().isFirstLaunch(),
                                   "Total Launches":WTracker.shared().totalLaunches(),
                                   "Read Status Count":readMIDs.count,
                                   "Delivered Status Count":deliveredMIDs.count]
    }
    
    override func parameters() -> NetworkDictionary {
        
        var params = super.parameters()
        
        if readMIDs.count > 0 {
            params["read"] = readMIDs.joined(separator: ",")
        }
        
        if deliveredMIDs.count > 0 {
            params["delivered"] = deliveredMIDs.joined(separator: ",")
        }
        
        return params
    }
}
