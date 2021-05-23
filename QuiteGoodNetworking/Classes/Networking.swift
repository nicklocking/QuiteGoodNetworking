import Foundation
import Alamofire

/**
 Maintains operation queues for submitting endpoint requests.
 */
open class Networking {
  
  /**
   This string will be prepended to all URLs, if present.
   */
  open var baseURLString: String?
  
  /**
   All HTTP endpoint requests and JSON encoding for those requests execute
   on this queue.
   */
  let httpRequestOperationQueue = OperationQueue()
  let httpRequestUnderlyingQueue = DispatchQueue(label: "quiteGoodNetworking.responseProcessorDispatchQueue")
  
  /**
   All responses to endpoint requests are processed here. The queue is specified
   manually because an Alamofire method needs a queue specified or it will use the main queue.
   */
  lazy var responseProcessorOperationQueue: OperationQueue = {
    let operationQueue = OperationQueue()
    operationQueue.underlyingQueue = httpRequestUnderlyingQueue
    return operationQueue
  }()
  
  public var authenticator: Authenticator?
  
  // Override Alamofire's default session manager here to configure things like timeouts.
  open var sessionManager: Alamofire.Session = {
    let configuration = URLSessionConfiguration.default
    return Alamofire.Session(configuration: configuration)
  }()
  
  required public init(baseURLString: String? = nil, authenticator: Authenticator?) {
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
    
    prepareRequest(httpRequest)
    
    switch httpRequest.queuingBehaviour {
    case .cancelIfRequestOfSameTypeExists:
      let countOfRequestsOfSameType = httpRequestOperationQueue.operations.filter { type(of: httpRequest) == type(of: $0) }
      if !countOfRequestsOfSameType.isEmpty {
        httpRequest.cancel()
        return
      }
    case .cancelExistingRequestsOfSameType:
      httpRequestOperationQueue.operations.filter { type(of: httpRequest) == type(of: $0)  }.forEach { $0.cancel() }
    case .cancelExistingEqualRequests:
      httpRequestOperationQueue.operations.filter { $0 == httpRequest }.forEach { $0.cancel() }
    default:
      break
    }
    
    httpRequestOperationQueue.addOperation(httpRequest)
    
  }
  
  public func prepareRequest(_ httpRequest: HTTPRequest) {
    addBaseURLString(httpRequest: httpRequest)
    httpRequest.networking = self
    httpRequest.sessionManager = sessionManager
  }
  
  // Overridable method to prepend a base URL to a given endpoint.
  open func addBaseURLString(httpRequest: HTTPRequest) {
    guard httpRequest.baseURLString == nil else {
      return
    }
    
    httpRequest.baseURLString = baseURLString
  }
  
}

extension Networking: AuthenticatorDelegate {
  
  public func pauseHTTPRequests() {
    httpRequestOperationQueue.isSuspended = true
  }
  
  public func resumeHTTPRequests() {
    httpRequestOperationQueue.isSuspended = false
  }
  
}
