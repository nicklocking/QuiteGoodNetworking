import Foundation
import Alamofire

/*
 Maintains operation queues for submitting endpoint requests.
 */
open class Networking {
    
    // Will be prepended to all URLs.
    open var baseURLString: String?

    // All HTTP endpoint requests run on this queue.
    let httpRequestOperationQueue = OperationQueue()
    
    // All responses to endpoint requests are processed here, on a separate queue.
    // This ensures that processing large chunks of JSON response and networking
    // don't choke processing.
    let responseProcessorOperationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.underlyingQueue = DispatchQueue(label: "quiteGoodNetworking.responseProcessorDispatchQueue")
        return operationQueue
    }()
 
    private var authenticator: Authenticator?
    
    private var responseResultStatusNotificationObserver = ResponseResultStatusNotificationObserver()
    
    // Override Alamofire's default session manager here to configure things like timeouts.
    open var sessionManager: Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        return Alamofire.SessionManager(configuration: configuration)
    }()

    required public init(baseURLString: String?, authenticator: Authenticator?) {
        self.baseURLString = baseURLString
        self.authenticator = authenticator
    }

    convenience public init() {
        self.init(baseURLString: nil, authenticator: nil)
    }
    
    // Cancels all requests in the operation queue, but not response processor operations.
    public func cancelAllRequests() {
        httpRequestOperationQueue.cancelAllOperations()
    }
    
    // Cancels all requests in the operation queue, as well as response processor operations in
    // the response processor queue.
    public func cancelAllOperations() {
        cancelAllRequests()
        responseProcessorOperationQueue.cancelAllOperations()
    }
    
    // Method to enqueue a request.
    public func enqueueHTTPRequest(_ httpRequest: HTTPRequest) {

        addBaseURLString(httpRequest: httpRequest)
        httpRequest.responseProcessorOperationQueue = responseProcessorOperationQueue
        httpRequest.sessionManager = sessionManager

        if let authenticatedHTTPRequest = httpRequest as? AuthenticatedHTTPRequest {
            if let authenticator = authenticator {
                authenticator.authenticateHTTPRequest(authenticatedHTTPRequest)
            } else {
               print("Attempting to authenticate an HTTP request without an authenticator set.")
            }
        }
        
        httpRequestOperationQueue.addOperation(httpRequest)
        
    }
    
    // Overridable method to prepend a base URL to a given endpoint.
    open func addBaseURLString(httpRequest: HTTPRequest) {
        httpRequest.baseURLString = baseURLString
    }
    
}

extension Networking: AuthenticatorDelegate {
    public func pauseHTTPRequests() {

    }
    
    public func resumeHTTPRequests() {

    }
    
}
