import Foundation

class ResponseResultStatusNotificationObserver: NSObject {
    
    override init() {

        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(httpRequestSuccess(notification:)), name: HTTPRequest.httpRequestSuccessNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(httpRequestSuccess(notification:)), name: HTTPRequest.httpRequestFailureNotificationName, object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    func httpRequestSuccess(notification: Notification) {
        guard let httpRequest = notification.userInfo?[HTTPRequest.httpRequestKey] as? HTTPRequest else {
            fatalError("Missing request in success notification.")
        }
        
        print("HTTP Request Success. \(httpRequest.buildURL()?.absoluteString ?? "")")
        print("Status Code: \(httpRequest.alamofireRequest?.response?.statusCode ?? -1)")
    }
    
    @objc
    func httpRequestFailure(notification: Notification) {
        guard let httpRequest = notification.userInfo?[HTTPRequest.httpRequestKey] as? HTTPRequest else {
            fatalError("Missing request in success notification.")
        }
        print("HTTP Request Failure. \(httpRequest.buildURL()?.absoluteString ?? "")")
        print("Status Code: \(httpRequest.alamofireRequest?.response?.statusCode ?? -1)")
        print("Body: \(String(describing: httpRequest.alamofireRequest))")
    }
    
}
