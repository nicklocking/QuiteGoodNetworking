import Foundation
import Alamofire

enum requestQueuingBehaviour {
    case none
    case cancelExistingSimilarRequests // Requests that are 'similar' to this one in the queue are cancelled.
    case cancelIfSimilarRequestExists // This request is cancelled if there is a similar one in the queue.
}

typealias RequestCompletionClosure = (_ HTTPRequest: HTTPRequest, _ response: DataResponse<Data>) -> Void

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
    open var queryStringParameters = NetworkParameterDictionary()
    open var bodyParameters = NetworkParameterDictionary()
    open var bodyData: Data?

    // Closures that will fire on success/failure/done. 'done' is always called,
    // regardless of success or failure. This is so you can, for example, remove
    // your spinner HUD on completion, regardless of whether the request succeeded.
    open var success: RequestCompletionClosure?
    open var failure: RequestCompletionClosure?
    open var completion: RequestCompletionClosure?

    // The response processor that will be created on completion of the request.
    open var responseProcessorType = ResponseProcessor.self
    
    // The operation queue the response processor will be enqueued to.
    public var responseProcessorOperationQueue: OperationQueue?
    
    // Underlying Alamofire request and response.
    public var alamofireRequest: Request?
    
    // Do the work of performing the actual request.
    override fileprivate func main() {
        
        if isCancelled {
            return
        }
        
        guard let url = buildURL() else {
            fatalError("No URL when attempting to perform an HTTP request.")
        }
        
        guard let sessionManager = sessionManager else {
            fatalError("Session manager is nil when trying to perform an HTTP request.")
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

    fileprivate func handleResponse(_ response: DataResponse<Data>) {

        guard isCancelled == false else {
            return
        }
        
        guard let responseProcessor = responseProcessorType?.init() else {
            fatalError("No response processor for request.")
        }

        guard responseProcessorOperationQueue != nil else {
            fatalError("No response processing queue for request.")
        }
        
        responseProcessor.httpRequest = self
        responseProcessor.success = success
        responseProcessor.failure = failure
        responseProcessor.completion = completion
        responseProcessor.alamofireDataResponse = response
        
        responseProcessorOperationQueue?.addOperation(responseProcessor)
        
        completeOperation()

    }
    
    /*
     Cancels the underlying AlamoFire request, nils all completion closures, and
     completes the operation. When you call cancel(), you are saying that you don't care
     about the operation any more, you don't want to see any return from it, and that it
     should be discarded immediately.
     */
    override fileprivate func cancel() {
        super.cancel()
        success = nil
        failure = nil
        completion = nil
        alamofireRequest?.cancel()
        completeOperation()
    }

}

/*
 Methods for use in building the underlying HTTP request.
 */
extension HTTPRequest {
    
    // Build a list of headers.
    func buildHeaders() -> [String: String]? {
        return headers
    }
    
    // Build a list of parameters for use in the query string
    func buildQueryStringParameters() -> NetworkParameterDictionary? {
        return queryStringParameters
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
    
}
