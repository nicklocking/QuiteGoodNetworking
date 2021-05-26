import Foundation
import Alamofire

/*
 Processes responses from HTTP requests. Can be overridden to add behaviours.
 */
open class ResponseProcessor: ConcurrentOperation {
  
  public var httpRequest: HTTPRequest?
  public var alamofireDataResponse: DataResponse<Data, AFError>?
  
  // Closures that will fire on success/failure/done. 'completion' is always called,
  // regardless of success or failure. This is so you can, for example, remove
  // your spinner HUD on completion, regardless of whether the request succeeded.
  open var success: RequestCompletionClosure?
  open var failure: RequestCompletionClosure?
  open var completion: RequestCompletionClosure?
  
  open var executesClosuresOnMainThread: Bool = false
  
  // Notifications that can be observed to detect/log success/failure of endpoints.
  static public let httpRequestSuccessNotificationName = NSNotification.Name(rawValue: "httpRequestSuccessNotification")
  static public let httpRequestFailureNotificationName = NSNotification.Name(rawValue: "httpRequestFailureNotification")
  static public let responseProcessorKey = "ResponseProcessor"
  
  //httpStatusCode = response.response?.statusCode
  //    var responseStatusCode: Int?
  //    var responseData: Data?
  //    var responseHeaders: NetworkParameterDictionary?
  
  required public override init() {
    super.init()
  }
  
  open func process() {
    // Stub method, override
  }
  
  override open func main() {
    
    guard Thread.current.isMainThread == false else {
      fatalError("Response processing should not be done on the main thread.")
    }
    
    guard isCancelled == false else {
      completeOperation()
      return
    }
    
    guard httpRequest != nil else {
      fatalError("Missing HTTP request in response processor.")
    }
    
    process()
    
    if executesClosuresOnMainThread && !Thread.isMainThread {
      DispatchQueue.main.async {
        self.executeClosures()
      }
    } else {
      executeClosures()
    }
    
    completeOperation()
  }
  
  private func executeClosures() {
    
    guard let alamofireDataResponse = alamofireDataResponse else {
      fatalError("Missing Alamofire data response in response processor.")
    }
    
    switch alamofireDataResponse.result {
      
    case .success:
      
      success?(self)
      NotificationCenter.default.post(name: ResponseProcessor.httpRequestSuccessNotificationName, object: nil, userInfo: [ResponseProcessor.responseProcessorKey: self])
      
    case .failure(let error):
      
      failure?(self)
      NotificationCenter.default.post(name: ResponseProcessor.httpRequestFailureNotificationName, object: error, userInfo: [ResponseProcessor.responseProcessorKey: self])
      
    }
    
    completion?(self)
  }
  
  open func responseData() -> Data {
    return alamofireDataResponse?.data ?? Data()
  }
  
}

/*
 Methods for acquiring the response in various formats.
 */
extension ResponseProcessor {
  
  public func httpStatusCode() -> Int {
    return alamofireDataResponse?.response?.statusCode ?? -1
  }
  
  public func responseJSON() -> Any? {
    return try? JSONSerialization.jsonObject(with: responseData(), options: [])
  }
  
  public func responseString() -> String {
    return String(data: responseData(), encoding: .utf8) ?? ""
  }
  
}
