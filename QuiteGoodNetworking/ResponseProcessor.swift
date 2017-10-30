import Foundation
import SwiftyJSON
import Alamofire

/*
Processes responses from HTTP requests. Can be overridden to add behaviours.
*/
open class ResponseProcessor: Operation {

    public var httpRequest: HTTPRequest?
    public var alamofireDataResponse: DataResponse<Data>?

    // Closures that will fire on success/failure/done. 'done' is always called,
    // regardless of success or failure. This is so you can, for example, remove
    // your spinner HUD on completion, regardless of whether the request succeeded.
    open var success: RequestCompletionClosure?
    open var failure: RequestCompletionClosure?
    open var completion: RequestCompletionClosure?
    
    // Notifications that can be observed to detect/log success/failure of endpoints.
    static let httpRequestSuccessNotificationName = NSNotification.Name(rawValue: "httpRequestSuccessNotification")
    static let httpRequestFailureNotificationName = NSNotification.Name(rawValue: "httpRequestFailureNotification")
    static let httpRequestKey = "request"

    //httpStatusCode = response.response?.statusCode
//    var responseStatusCode: Int?
//    var responseData: Data?
//    var responseHeaders: NetworkParameterDictionary?

    open func process() {
        // Stub method, override
    }
    
    override fileprivate func main() {

        guard Thread.current.isMainThread == false else {
            fatalError("Response processing should not be done on the main thread.")
        }
        
        guard isCancelled == false else {
            return
        }

        guard let httpRequest = httpRequest else {
            fatalError("Missing HTTP request in response processor.")
        }

        process()
        
        switch response.result {
            
        case .success:
            
            success?(httpRequest, response)
            NotificationCenter.default.post(name: HTTPRequest.httpRequestSuccessNotificationName, object: nil, userInfo: [HTTPRequest.httpRequestKey: self])
            
        case .failure:
            
            failure?(httpRequest, response)
            NotificationCenter.default.post(name: HTTPRequest.httpRequestFailureNotificationName, object: nil, userInfo: [HTTPRequest.httpRequestKey: self])
            
        }

        completion?(httpRequest, response)
        
    }
    
}

/*
 Methods for acquiring the response in various formats.
 */
extension ResponseProcessor {

//    public func responseDictionary() -> NetworkParameterDictionary? {
//
//        guard let responseJSON = responseJSON() else {
//            return nil
//        }
//
//
//        return responseJSON.dictionaryObject as? NetworkParameterDictionary
//
//    }
//
    public func responseJSON() -> JSON? {
        guard let responseData = responseData() else {
            return nil
        }
        
        let json = try? JSON(data: responseData)
        
        return json
    }

    public func responseString() -> String {
        return String(describing: responseJSON())
    }
    
    public func responseData() -> Data? {
        return httpRequest?.alamofireDataResponse?.data
    }
    
}
