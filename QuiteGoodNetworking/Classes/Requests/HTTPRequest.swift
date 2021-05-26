import Foundation
import Alamofire
import CoreGraphics

public enum RequestQueuingBehaviour {
  case none
  case cancelExistingRequestsOfSameType
  case cancelIfRequestOfSameTypeExists
  case cancelExistingEqualRequests
}

public typealias RequestCompletionClosure = (_ responseProcessor: ResponseProcessor) -> Void
public typealias RequestProgressClosure = (_ progress: CGFloat) -> Void

/*
 Base class for an http request operation.
 */
@objc
open class HTTPRequest: ConcurrentOperation {
  
  override required public init() {
    super.init()
  }
  
  // Alamofire's session manager
  open var sessionManager: Session?
  
  // Details about the request.
  open var httpMethod = HTTPMethod.get
  open var baseURLString: String?
  open var path: String? {
    // Sometimes paths come in like /somePath?someParam=someValue. This creates problems if we try and append
    // another query string on the end so we pull them off and convert them.
    didSet {
      
      guard path?.contains("?") == true else {
        return
      }

      guard let components = path?.split(separator: "?"), components.count == 2, let queryString = components.last, let truncatedPath = components.first else {
        return
      }
      
      var urlComponents = URLComponents()
      urlComponents.query = String(queryString)
      
      urlComponents.queryItems?.forEach { (urlQueryItem) in
        queryStringParameters[urlQueryItem.name] = urlQueryItem.value
      }

      path = String(truncatedPath)
      
    }
  }
  open var encodingMethod: ParameterEncoding = URLEncoding(destination: .methodDependent)
  open var acceptableContentTypes = [String]()
  open var headers = [String: String]()
  open var queryStringParameters = NetworkParameterDictionary()
  open var bodyParameters = NetworkParameterDictionary()
  open var bodyData: Data? // If present, will be transmitted as the body.
  open var sourceURL: URL? // If present, will be transmitted as the body, streamed from disk.
  open var queuingBehaviour = RequestQueuingBehaviour.none
  
  // Closures that will fire on success/failure/progress/done. 'done' is always
  // called, regardless of success or failure. This is so you can, for example,
  // remove your spinner HUD on completion, regardless of whether the request succeeded.
  open var success: RequestCompletionClosure?
  open var failure: RequestCompletionClosure?
  open var progress: RequestProgressClosure?
  open var completion: RequestCompletionClosure?
  open var executesClosuresOnMainThread: Bool = false
  
  // The response processor that will be created on completion of the request.
  open var responseProcessorType = ResponseProcessor.self
  
  // The Networking management object..
  public var networking: Networking?
  
  // Underlying Alamofire request and response.
  public var alamofireRequest: Request?
  
  // Do the work of performing the actual request.
  override open func main() {
    
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
    
    if let authenticatedHTTPRequest = self as? AuthenticatedHTTPRequest {
      networking?.authenticator?.authenticate(authenticatedHTTPRequest)
    }
    
    if let sourceURL = sourceURL {
      request = sessionManager.upload(sourceURL,
                                      to: url,
                                      method: httpMethod,
                                      headers: buildHeaders(),
                                      interceptor: interceptor()).uploadProgress(closure: { [weak self] (progress) in
        self?.progress?(CGFloat(progress.fractionCompleted))
      })
    } else if let bodyData = bodyData {
      request = sessionManager.upload(bodyData,
                                      to: url,
                                      method: httpMethod,
                                      headers: buildHeaders(),
                                      interceptor: interceptor()).uploadProgress(closure: { [weak self] (progress) in
        self?.progress?(CGFloat(progress.fractionCompleted))
      })
    } else {
      request = sessionManager.request(url, method: httpMethod,
                                       parameters: buildBodyParameters(),
                                       encoding: encodingMethod,
                                       headers: buildHeaders(),
                                       interceptor: interceptor()).downloadProgress(closure: { [weak self] (progress) in
        self?.progress?(CGFloat(progress.fractionCompleted))
                                       })
    }
    
    guard request != nil else {
      fatalError("Failed to make an alamofire request.")
    }
    let queue = networking?.responseProcessorOperationQueue.underlyingQueue ?? .main
    let successCodes = 200..<300
    var emptyResponseCodes = JSONResponseSerializer.defaultEmptyResponseCodes
    for code in successCodes {
      emptyResponseCodes.insert(code)
    }
    request?.validate(statusCode: successCodes)
      .validate(contentType: self.acceptableContentTypes)
      .responseData(queue: queue,
                    emptyResponseCodes: emptyResponseCodes,
                    completionHandler: handleResponse)
  }
  
  fileprivate func handleResponse(_ response: DataResponse<Data, AFError>) {
    
    guard isCancelled == false else {
      return
    }
    
    if networking?.authenticator?.shouldReauthenticateAndRetry(request: self, response: response) == true {
      networking?.authenticator?.authenticate()
      networking?.enqueueHTTPRequest(self.copy() as! HTTPRequest)
      return
    }
 
    let responseProcessor = responseProcessorType.init()
    
    responseProcessor.httpRequest = self
    responseProcessor.success = success
    responseProcessor.failure = failure
    responseProcessor.completion = completion
    responseProcessor.executesClosuresOnMainThread = executesClosuresOnMainThread
    responseProcessor.alamofireDataResponse = response

    guard networking?.responseProcessorOperationQueue != nil else {
      fatalError("No response processing queue for request.")
    }
  
    networking?.responseProcessorOperationQueue.addOperation(responseProcessor)
    
    completeOperation()
    
  }
  
  /**
   Cancels the underlying AlamoFire request, and nils all completion closures. When you call
   cancel(), you are saying that you don't care about the operation any more, you don't want
   to see any return from it, and that it should be discarded immediately. The superclass'
   implementation calls completeOperation() so it is not necessary to call it again here.
   In other methods that check for cancellation, they do not call completeOperation() or
   anything that is called by this method, as that would be redundant.
   */
  override open func cancel() {
    success = nil
    failure = nil
    completion = nil
    alamofireRequest?.cancel()
    super.cancel()
  }

  /*
   Methods for use in building the underlying HTTP request.
   */
  
  // Build a list of headers.
  open func buildHeaders() -> HTTPHeaders? {
    return HTTPHeaders(headers)
  }
  
  // Build a list of parameters for use in the query string
  open func buildQueryStringParameters() -> NetworkParameterDictionary? {
    return queryStringParameters
  }
  
  // Build a list of parameters for use in the body
  open func buildBodyParameters() -> NetworkParameterDictionary? {
    return bodyParameters.isEmpty ? nil : bodyParameters
  }
  
  open func interceptor() -> RequestInterceptor? {
    return nil
  }
  
  // Build a URL string from the base url, path and query parameters.
  open func buildURL() -> URL? {
    
    var urlString = ""
    
    if let baseURLString = baseURLString {
      urlString.append(baseURLString)
    }
    
    if let path = path {
      urlString.append(path)
    }
    
    if let queryParametersString = buildQueryStringParameters()?.queryStringParametersString(), queryParametersString.count > 0 {
      urlString.append("?\(queryParametersString)")
    }
    
    return URL(string: urlString)
    
  }
  
  open override func isEqual(_ object: Any?) -> Bool {
    guard let otherRequest = object as? HTTPRequest else {
        return false
    }
    return self.path == otherRequest.path && type(of: self) == type(of: object)
  }
  
}

extension HTTPRequest: NSCopying {
  
  @objc
  open func copyProperties(to copiedHTTPRequest: HTTPRequest) {
    
    copiedHTTPRequest.sessionManager = sessionManager
    copiedHTTPRequest.httpMethod = httpMethod
    copiedHTTPRequest.baseURLString = baseURLString
    copiedHTTPRequest.path = path
    copiedHTTPRequest.encodingMethod = encodingMethod
    copiedHTTPRequest.acceptableContentTypes = acceptableContentTypes
    copiedHTTPRequest.headers = headers
    copiedHTTPRequest.queryStringParameters = queryStringParameters
    copiedHTTPRequest.bodyParameters = bodyParameters
    copiedHTTPRequest.bodyData = bodyData
    copiedHTTPRequest.sourceURL = sourceURL
    copiedHTTPRequest.success = success
    copiedHTTPRequest.failure = failure
    copiedHTTPRequest.progress = progress
    copiedHTTPRequest.completion = completion
    copiedHTTPRequest.responseProcessorType = responseProcessorType
    copiedHTTPRequest.networking = networking
    copiedHTTPRequest.alamofireRequest = alamofireRequest
    copiedHTTPRequest.executesClosuresOnMainThread = executesClosuresOnMainThread
    copiedHTTPRequest.queuingBehaviour = queuingBehaviour

  }
  
  public func copy(with zone: NSZone? = nil) -> Any {

    let copiedHTTPRequest = type(of: self).init()
    copyProperties(to: copiedHTTPRequest)
    return copiedHTTPRequest
    
  }
  
}
