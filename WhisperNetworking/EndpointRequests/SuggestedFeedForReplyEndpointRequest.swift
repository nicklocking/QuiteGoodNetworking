import Foundation

class SuggestedFeedForReplyEndpointRequest: EndpointRequest {
    
    let wid: String
    
    required init(replyWID: String) {
        
        self.wid = replyWID
        super.init()
        
        httpMethod = .get
        path = "/whisper/\(replyWID)/related"
    }
    
    override func createResponseProcessor() {
        responseProcessor = SuggestedFeedForReplyResponseProcessor(replyWID: wid)
    }
}
