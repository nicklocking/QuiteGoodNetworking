import Foundation
import Alamofire
import SwiftyJSON

/*
 Abstract base class for an endpoint operation.
 */
open class EndpointRequest: ConcurrentOperation, NSCopying {
    
    var httpMethod = HTTPMethod.get
    
    var baseURLString: String { get { return "https://prod.whisper.sh" } }
    var path = ""
    
    var responseProcessorType:ResponseProcessor.Type?
    var responseProcessor: ResponseProcessor?
    
    var encodingMethod: ParameterEncoding = URLEncoding(destination: .methodDependent)
    
    var endpointRequest: Request?
    var error: Error?
    var errorsFromServerForDebug: [String]?
    var errorFromServerForDisplay: String?
    
    var success:((_ endpointRequest: EndpointRequest) -> Void)?
    var failure:((_ endpointRequest: EndpointRequest) -> Void)?
    var done:((_ endpointRequest: EndpointRequest) -> Void)?
    
    /// The default failure message for this endpoint, such as "Oops, we couldn't create this group."
    var defaultFailureMessage = NSLocalizedString("Oops, we couldn't complete this action!", comment: "")
    /// A mapping from HTTP status code to an error message.  Can be modified per-request.
    var failureHTTPCodeToMessage = [Int: String]()
    
    var httpStatusCode: Int?
    var responseJSON: JSON?
    var responseData: Data?
    var errorJSON: JSON? /// We use SwiftyJSON to parse JSON on an error response, which is different from what Alamofire uses
    
    var requiresAuthenticatedUser = false
    
    var queryParams: NetworkOptionalsDictionary?
    var extraParameters: NetworkOptionalsDictionary?
    
    var errorTrackingProperties: NetworkOptionalsDictionary?
    
    var httpBodyData: Data?
    
    var exponentialBackoffDelay: TimeInterval = 5 * 60

    var timeoutDelay: TimeInterval = 30
        
    override open func main() {
        
        // Some endpoints are useless without a user - this blocks the operation until we get a user.
        if requiresAuthenticatedUser && user() == nil {
            NotificationCenter.default.addObserver(self, selector: #selector(gotUserNotification), name: NSNotification.Name(rawValue: System.gotUserNotification), object: nil)
            return
        }
        
        performRequest()
        
    }

    func performRequest() {
        
        if isCancelled {
            NotificationCenter.default.removeObserver(self)
            return
        }

        let url = URL(string: urlString())!
        
        if let localHTTPBodyData = httpBodyData {
            endpointRequest = system().alamofireSessionManager.upload(localHTTPBodyData, to: url, method: httpMethod, headers: headers())
                .validate()
                .responseData(completionHandler: self.handleResponse)
        } else {
            endpointRequest = system().alamofireSessionManager.request(url, method: httpMethod, parameters: parameters(), encoding: encodingMethod, headers: headers())
                .validate()
                // TODO: We should use responseJSON once we are certain that the server will always send down JSON. Right now there are endpoints that send down "200 OK"
                .responseData(completionHandler: self.handleResponse)
        }
    }
    
    func handleResponse(_ response: DataResponse<Data>) {
        
        if isCancelled {
            return
        }
        
        httpStatusCode = response.response?.statusCode

        switch response.result {
            
        case .success(let data):
            
            responseJSON = JSON(data: data)
            responseData = data
            didCompleteRequestSuccessfully()
        
        case .failure(let error):
            
            if let urlString = response.request?.url?.absoluteURL {
                print(urlString)
            }
            print(error.localizedDescription)
            
            if let data = response.data {
                errorJSON = JSON(data: data)
            }
            self.error = error
            
            didFailRequest()
        }
        
        completeOperation()
    }
    
    // We have this for objective-c, which can't read out Int?
    func statusCode() -> Int {
        if let statusCode = httpStatusCode {
            return statusCode
        }
        return -1
    }
    
    // Stop the notification from being fired if the request gets canceled
    override open func cancel() {
        super.cancel()
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: System.gotUserNotification), object: nil)
    }

    func gotUserNotification(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: System.gotUserNotification), object: nil)
        main()
    }
    
    func urlString() -> String {
        assert(path.characters.first == "/" || path.characters.count == 0, "The path needs to start with a /")
        
        let queryParams = queryParamsString()
        if queryParams == "" {
            return baseURLString + path
        } else {
            return baseURLString + path + "?" + queryParamsString()
        }
    }
    
    func authenticatedURLString(_ command: String) -> String {

        let authenticationParameters = WSecurity.legacyAuthenticationParams(for: system().user)
        
        guard
            let uid = authenticationParameters?["uid"] as? String,
            let authToken = authenticationParameters?["auth_token"] as? String,
            let nonce = authenticationParameters?["nonce"] as? String else
        {
            return ""
        }
        
        return "\(command)/\(uid)/\(authToken)/\(nonce)"
    }
    
    func queryParamsString() -> String {
        switch type(of:encodingMethod) {
        case is JSONEncoding.Type:
            if let _ = queryParams {
                queryParams!["uid"] = system().user?.uid
                break
            }
            queryParams = ["uid": system().user?.uid]
            break
        default: break
        }
        
        guard let safeQueryParams = queryParams?.withoutNilKeys() as? NetworkOptionalsDictionary else {
            return ""
        }
        
        let arrayOfQueryParams: [String] = safeQueryParams.flatMap { (key: String, value: NetworkParameter?) -> String? in

            guard
                let localValue = value,
                let component = "\(key)=\(localValue)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else
            {
                return nil
            }
            
            return component
            
        }
        
        return arrayOfQueryParams.joined(separator: "&")
    }
    
    func parameters() -> NetworkDictionary {
        var params = NetworkDictionary()
        
        if
            let uid = system().user?.uid,
            let pin = system().user?.pin,
            let authenticationDictionary = WSecurity.legacyAuthenticationParams(forPIN: pin, uid: uid),
            let authenticationParameters = authenticationDictionary as? Dictionary<String, NetworkParameter>
        {
            params += authenticationParameters
        } else if let authenticationParameters = (WSecurity.unauthenticatedHeadersWithoutUid() as NSDictionary) as? NetworkDictionary {
            params += authenticationParameters
        }

        if let localExtraParameters = extraParameters?.convertToNetworkDictionary() {
            params += localExtraParameters
        }
        
        // We want to get it from the source as it could've been niled out or any other thing while we were getting the data
        if WLocationManager.shared().hasLastLocation {
            params["lat"] = WLocationManager.shared().lastLatitude
            params["lon"] = WLocationManager.shared().lastLongitude
        }
        
        return params
    }
    
    func headers() -> [String: String] {
        return EndpointRequestHeaders.headers() 
    }
    
    func didCompleteRequestSuccessfully() {
        
        if let sessionToken = endpointRequest?.response?.allHeaderFields["session_token"] as? String , sessionToken != user()?.userAccount?.sessionToken {
            user()?.userAccount?.sessionToken = sessionToken
        }
        
        // handle "304: Not Modified" response
        // which should just run the success block
        if httpStatusCode == .notModified {
            success?(self)
            done?(self)
            return
        }
        
        createResponseProcessor()
        guard let localResponseProcessor = responseProcessor else {
            success?(self)
            done?(self)
            return
        }
        
        localResponseProcessor.completionBlock = { [localSuccess = success, localDone = done] _ in
            localSuccess?(self)
            localDone?(self)
            // Prevents a retain cycle
            self.responseProcessor?.completionBlock = nil
        }
        localResponseProcessor.responseData = responseData
        localResponseProcessor.responseHeaders = (endpointRequest?.response?.allHeaderFields as! NetworkDictionary)
        localResponseProcessor.responseJSON = responseJSON?.rawValue as? NetworkParameter
        localResponseProcessor.responseStatusCode = statusCode()
        system().responseProcessingOperationQueue.addOperation(localResponseProcessor)
    }
    
    func didFailRequest() {
        
        createResponseProcessor()
        guard let localResponseProcessor = responseProcessor else {
            failure?(self)
            done?(self)
            return
        }
        
        localResponseProcessor.errorJSON = errorJSON
        localResponseProcessor.responseStatusCode = statusCode()
        errorsFromServerForDebug = localResponseProcessor.errorsFromServerForDebug
        errorFromServerForDisplay = localResponseProcessor.errorFromServerForDisplay
        
        localResponseProcessor.processErrorResponse()
        failure?(self)
        done?(self)
        fireHTTPErrorTrackingEvent()
    }
    
    func createResponseProcessor() {
        guard let localResponseProcessorType = responseProcessorType else {
            return
        }
        
        responseProcessor = localResponseProcessorType.init()
    }
    
    func fireHTTPErrorTrackingEvent() {
        
        let className = NSStringFromClass(type(of: self)).components(separatedBy: ".").last ?? "EndpointRequest"
        
        EndpointRequestErrorTrackingEvent(endpoint: className, path: path, httpStatusCode: statusCode(), error: error, properties: errorTrackingProperties).submit()
 
    }
    
    //Should be overriden by all subclasses
    open func copy(with zone: NSZone?) -> Any {
        fatalError("Must override copyWithZone on all subclassses of EndpointRequest")
    }
    
    class func setETag(_ eTag: String?) {
        UserDefaults.standard.set(eTag, forKey: String(describing: self) + "_etag_key")
        UserDefaults.standard.synchronize()
    }
    
    class func getETag() -> String? {
        return UserDefaults.standard.string(forKey: String(describing: self) + "_etag_key")
    }
}
