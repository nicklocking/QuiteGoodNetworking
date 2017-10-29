import Foundation

class FetchTribeMembersListEndpointRequest: EndpointRequest {

    var offset = 0
    var tribeID: String
    var scrollID: String?
    var shouldDeleteExistingMembers = false
    
    required init(tribeID: String) {
        
        self.tribeID = tribeID
        
        super.init()
       
        path = "/feeds/subscribers"
        
        responseProcessorType = FetchTribeMembersListResponseProcessor.self
        
    }
 
    override func parameters() -> NetworkDictionary {
        
        var parameters = super.parameters()

        if let uid = system().user?.uid {
            parameters["uid"] = uid
        }
        
        parameters["feed_id"] = tribeID
        
        if let localScrollID = scrollID {
            parameters["scroll_id"] = localScrollID
        }
        
        if offset != 0 {
            parameters["offset"] = offset
        }
        
        return parameters
    }
    
    override func createResponseProcessor() {
        super.createResponseProcessor()
        
        guard let localResponseProcessor = responseProcessor as? FetchTribeMembersListResponseProcessor else {
            return
        }

        localResponseProcessor.tribeID = tribeID
        localResponseProcessor.shouldDeleteExistingMembers = shouldDeleteExistingMembers
    }

}
