import Foundation
import SwiftyJSON
import Alamofire

/*
Abstract base class to deal with processing responses from endpoints.
*/
open class ResponseProcessor: Operation {

    public var httpRequest: HTTPRequest?

    //httpStatusCode = response.response?.statusCode
//    var responseStatusCode: Int?
//    var responseData: Data?
//    var responseHeaders: NetworkParameterDictionary?
    
    var completion:((_ HTTPRequest: HTTPRequest) -> Void)?

    required override public init() {
        super.init()
    }
    
    open func process() {
        // Stub method, override
    }
    
    /// Don't override this unless you really have to; work should be done in `process()`
    override open func main() {

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
        
        completion?(httpRequest)
        
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
