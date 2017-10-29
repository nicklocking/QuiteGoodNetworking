import Foundation
import Alamofire
import SwiftyJSON

enum requestQueuingBehaviour {
    case none
    case cancelExistingSimilarRequests // Requests that are 'similar' to this one in the queue are cancelled.
    case cancelIfSimilarRequestExists // This request is cancelled if there is a similar one in the queue.
}

/*
 Base class for an http request operation.
 */
@objc
open class HTTPRequest: ConcurrentOperation {
    
    // Alamofire's session manager
    var sessionManager: SessionManager?
    
    // Details about the request.
    open var httpMethod = HTTPMethod.get
    open var baseURLString: String?
    open var path: String?
    open var encodingMethod: ParameterEncoding = URLEncoding(destination: .methodDependent)
    open var headers = [String: String]()
    open var queryParameters = NetworkParameterDictionary()
    open var bodyParameters = NetworkParameterDictionary()
    open var bodyData: Data?

    // Closures that will fire on success/failure/done. 'done' is always called,
    // regardless of success or failure. This is so you can, for example, remove
    // your spinner HUD on completion, regardless of whether the request succeeded.
    open var success:((_ HTTPRequest: HTTPRequest) -> Void)?
    open var failure:((_ HTTPRequest: HTTPRequest) -> Void)?
    open var completion:((_ HTTPRequest: HTTPRequest) -> Void)?

    // Notifications that can be observed to detect/log success/failure of endpoints.
    static let httpRequestSuccessNotificationName = NSNotification.Name(rawValue: "httpRequestSuccessNotification")
    static let httpRequestFailureNotificationName = NSNotification.Name(rawValue: "httpRequestFailureNotification")
    static let httpRequestKey = "request"
    
    // The response processor that will be created on completion of the request.
    open var responseProcessorType: ResponseProcessor.Type?
    
    // The response processor will be enqueued to this operation queue.
    public var responseProcessorOperationQueue: OperationQueue?
    
    // Underlying Alamofire request and response.
    public var alamofireRequest: Request?
    public var alamofireDataResponse: DataResponse<Data>?
    
    // Operation's entry point method. Should not be overridden.
    override open func main() {
        
        performRequest()
        
    }
    
    // Build a list of headers.
    func buildHeaders() -> [String: String]? {
        return headers
    }
    
    // Build a list of parameters for use in the query string
    func buildQueryParameters() -> NetworkParameterDictionary? {
        return queryParameters
    }
    
    // Build a list of parameters for use in the body
    func buildBodyParameters() -> NetworkParameterDictionary? {
        return bodyParameters
    }
    
    // Build a URL string from the base url, path and query parameters.
    func buildURL() -> URL? {
        
        var urlString = ""
        
        if let baseURLString = baseURLString {
            urlString.append(baseURLString)
        }
        
        if let path = path {
            urlString.append(path)
        }
        
        let queryParametersString = queryParameters.queryParametersString()
        if queryParametersString.characters.count > 0 {
            urlString.append("?\(queryParametersString)")
        }
        
        return URL(string: urlString)

    }
    
    // Do the work of performing the actual request. If this method returns early,
    // completeOperation() must be called.
    func performRequest() {
        
        if isCancelled {
            completeOperation()
            return
        }

        guard let url = buildURL() else {
            fatalError("No URL when attempting to perform an HTTP request.")
        }
        
        guard let sessionManager = sessionManager else {
            fatalError("Session manager is nil when trying to perform an HTTP request.")
        }

        guard let responseProcessorDispatchQueue = responseProcessorOperationQueue?.underlyingQueue else {
            fatalError("Response procssor dispatch queue is nil when trying to perform an HTTP request.")
        }
        
        var request: DataRequest?
        
        if let bodyData = bodyData {
            request = sessionManager.upload(bodyData, to: url, method: httpMethod, headers: buildHeaders())
        } else {
            // TODO: pretty sure this needs to be non-optionals
            // buildBodyParameters()
//            let tmp = ["1": "1", "2": "nil"]
            request = sessionManager.request(url, method: httpMethod, parameters: buildBodyParameters(), encoding: encodingMethod, headers: buildHeaders())
        }

        guard let _ = request else {
            fatalError("Failed to make an alamofire request.")
        }
        
        request?.validate().responseData(queue: responseProcessorDispatchQueue, completionHandler: handleResponse)

    }
    
    // Once the request completes, this is called. No matter what happens with the response,
    // this method will be called.
    func handleResponse(_ response: DataResponse<Data>) {
        
        guard Thread.current.isMainThread == false else {
            fatalError("HTTP requests should not be performed on the main thread.")
        }
        
        // This method MUST call completeOperation() at some point, or the operation will
        // stay in the queue forever.
        defer {
            completeOperation()
        }
        
        guard isCancelled == false else {
            return
        }
        
        var successOrFailureClosure: ((_ HTTPRequest: HTTPRequest) -> Void)?

        alamofireDataResponse = response

        switch response.result {
            
        case .success:

            successOrFailureClosure = success
            NotificationCenter.default.post(name: HTTPRequest.httpRequestSuccessNotificationName, object: nil, userInfo: [HTTPRequest.httpRequestKey: self])
            
        case .failure:

            successOrFailureClosure = failure
            NotificationCenter.default.post(name: HTTPRequest.httpRequestFailureNotificationName, object: nil, userInfo: [HTTPRequest.httpRequestKey: self])

        }

        let finalCompletionClosure: ((_ HTTPRequest: HTTPRequest) -> Void) = { [successOrFailureClosure, completion] (self) in
            successOrFailureClosure?(self)
            completion?(self)
        }
        
        // If there's no response processor attached, this method will simply run the completion
        // blocks. If there is, the completion closures will be added to the response processor
        // and it will be added to the response processing queue. It's important not to retain
        // the response processor or there'll be a retain cycle.
        if let responseProcessor = responseProcessorType?.init() {

            guard responseProcessorOperationQueue != nil else {
                fatalError("Attempting to run a response processor with no response processing queue.")
            }

            responseProcessor.httpRequest = self
            responseProcessor.completion = finalCompletionClosure

            responseProcessorOperationQueue?.addOperation(responseProcessor)

        } else {
            
            finalCompletionClosure(self)
            
        }
        
    }
    
    /*
     Cancels the underlying AlamoFire request, nils all completion closures, and
     completes the operation. When you call cancel(), you are saying that you don't care
     about the operation any more, you don't want to see any return from it, and that it
     should be discarded immediately.
     */
    override open func cancel() {
        super.cancel()
        success = nil
        failure = nil
        completion = nil
        alamofireRequest?.cancel()
        completeOperation()
    }

}
