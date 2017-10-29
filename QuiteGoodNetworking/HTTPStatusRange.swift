/*
 Enum for HTTP status codes for use in broader comparisons, i.e. you want to check
 whether a status code is any kind of server error and you don't care which specific
 type.
 */
enum HTTPStatusCodeRange: Int {
    
    case informational = 100
    case ok = 200
    case redirect = 300
    case invalidRequest = 400
    case serverError = 500
    
    init(httpStatusCode:HTTPStatusCode) {
        let httpStatusCodeRange = (httpStatusCode.rawValue / 100) * 100
        self.init(rawValue: httpStatusCodeRange)!
    }

    // Does this range contain this status code?
    func contains(_ httpStatusCode: HTTPStatusCode) -> Bool {
        return HTTPStatusCodeRange(httpStatusCode: httpStatusCode) == self
    }
    
}
