import Foundation

/**
 Observes notifications that are fired by requests failing or succeeding, and logs them
 to the console. For use in debugging.
 */
open class ResponseResultStatusNotificationObserver: NSObject {
  
  override public init() {
    
    super.init()
    
    NotificationCenter.default.addObserver(self, selector: #selector(httpRequestSuccess(notification:)), name: ResponseProcessor.httpRequestSuccessNotificationName, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(httpRequestFailure(notification:)), name: ResponseProcessor.httpRequestFailureNotificationName, object: nil)
    
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc
  final func httpRequestSuccess(notification: Notification) {
    guard let responseProcessor = notification.userInfo?[ResponseProcessor.responseProcessorKey] as? ResponseProcessor else {
      fatalError("Missing request in success notification.")
    }
    
    //        print("HTTP Request Success. \(responseProcessor.httpRequest?.buildURL()?.absoluteString ?? "")")
    //        print("Status Code: \(responseProcessor.alamofireDataResponse?.response?.statusCode ?? -1)")
    
    requestDidSucceed(responseProcessor)
  }
  
  open func requestDidSucceed(_ responseProcessor: ResponseProcessor) {
    
  }
  
  @objc
  final func httpRequestFailure(notification: Notification) {
    guard let responseProcessor = notification.userInfo?[ResponseProcessor.responseProcessorKey] as? ResponseProcessor else {
      fatalError("Missing request in success notification.")
    }
    
    requestDidFail(responseProcessor)
    
    print("HTTP Request Failure. \(responseProcessor.httpRequest?.buildURL()?.absoluteString ?? "")")
    print("Status Code: \(responseProcessor.alamofireDataResponse?.response?.statusCode ?? -1)")
    print("Body: \(String(describing: responseProcessor.httpRequest?.alamofireRequest))")
    
  }
  
  open func requestDidFail(_ responseProcessor: ResponseProcessor) {
    
  }
  
}
