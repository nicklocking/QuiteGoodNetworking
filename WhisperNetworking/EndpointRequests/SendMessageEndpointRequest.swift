class SendMessageEndpointRequest: MessagingEndpointRequest {
    
    enum MessageType {
        case image, giphy, text
        
        static let imageString = "Image"
        static let giphyString = "Gif"
        static let textString = "Message"
        
        func name() -> String {
            switch self {
            case .image: return MessageType.imageString
            case .giphy: return MessageType.giphyString
            case .text: return MessageType.textString
            }
        }
    }
    
    var groupToken: String
    var messageBody: String
    var localMID: String
    var messageType: MessageType = .text
    var conversationWID: String
    var isImage = false
    
    required init(groupToken: String, messageBody: String, localMID: String, conversationWID: String, conversationCID: String, conversationMessageCount: Int, isImage: Bool, isValidGiphyMessage: Bool) {
        
        self.groupToken = groupToken
        self.messageBody = messageBody
        self.localMID = localMID
        self.conversationWID = conversationWID
        self.isImage = isImage
        
        if isImage {
            messageType = .image
        } else if isValidGiphyMessage {
            messageType = .giphy
        }
        
        super.init()
        
        path = "/v1/message?response_format=message"
        
        httpMethod = .post
        
        responseProcessorType = SendMessageResponseProcessor.self
        
        var trackingProperties: NetworkOptionalsDictionary = ["First Launch":WTracker.shared().isFirstLaunch(),
                                                       "Total Launches":WTracker.shared().totalLaunches(),
                                                       "Retry":false,
                                                       "wid":self.conversationWID,
                                                       "cid":conversationCID,
                                                       "Group Token":self.groupToken,
                                                       "Message Count":conversationMessageCount]
        
        trackingProperties["Content"] = self.isImage ? "Image" : "Text"
        trackingProperties["Text Length"] = self.isImage ? nil : self.messageBody.characters.count
        errorTrackingProperties = trackingProperties
        
        if isImage {

            guard let imageData = try? Data(contentsOf: URL(fileURLWithPath: WMessageImagePath(self.localMID))) else {
                return
            }
            
            let name = "attachment"
            let mimetype = "application/octet-stream"
            let filename = "file"
            let boundary = "0xKhTmLbOuNdArY"
            
            let headerTTLFieldString = "--\(boundary)\r\nContent-Disposition: form-data; name=\"ttl\"\r\n\r\n2880\r\n"
            let headerRecipientFieldString = "--\(boundary)\r\nContent-Disposition: form-data; name=\"recipient\"\r\n\r\n\(groupToken)\r\n"
            let headerBodyFieldString = "--\(boundary)\r\nContent-Disposition: form-data; name=\"body\"\r\n\r\n\(messageBody)\r\n"
            let bodyFieldString = "--\(boundary)\r\nContent-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\nContent-Type: \(mimetype)\r\nContent-Transfer-Encoding: binary\r\n\r\n"
            
            guard
                let headerData = "\(headerTTLFieldString)\(headerRecipientFieldString)\(headerBodyFieldString)".data(using: String.Encoding.utf8),
                let bodyFieldData = bodyFieldString.data(using: String.Encoding.utf8),
                let tailData = "\r\n--\(boundary)--\r\n".data(using: String.Encoding.utf8) else
            {
                return
            }
            
            let bodyData = NSMutableData()
            bodyData.append(headerData)
            bodyData.append(bodyFieldData)
            bodyData.append(imageData)
            bodyData.append(tailData)
        
            httpBodyData = bodyData as Data
        }
    }
    
    override func headers() -> [String : String] {
        var headers = super.headers()
        
        if
            let bodyData = httpBodyData,
            isImage
        {
            let boundary = "0xKhTmLbOuNdArY"
            let charset = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue))!
            headers["Content-Type"] = "multipart/form-data; charset=\(charset); boundary=\(boundary)"
            headers["Content-Length"] = "\(bodyData.count)"
        }
        
        return headers
    }
    
    override func parameters() -> NetworkDictionary {
        return super.parameters() + ["recipient":groupToken, "ttl":2880, "body":messageBody]
    }
    
    override func createResponseProcessor() {
        super.createResponseProcessor()
        
        if let localResponseProcessor = responseProcessor as? SendMessageResponseProcessor {
            localResponseProcessor.localMID = localMID
            localResponseProcessor.responseStatusCode = statusCode()
        }
    }
    
    override func didCompleteRequestSuccessfully() {
        super.didCompleteRequestSuccessfully()
        WTracker.shared().trackMessagingSent(true, wid: conversationWID, messageType: messageType.name())
    }
    
    override func didFailRequest() {
        super.didFailRequest()
        WTracker.shared().trackMessagingSent(false, wid: conversationWID, messageType: messageType.name())
    }
    
}
