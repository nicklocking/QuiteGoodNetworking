import XCTest
@testable import QuiteGoodNetworking

class HTTPStatusRangeTests: XCTestCase {
    
    func testHTTPStatusCodeEquality() {

        assert(404 == HTTPStatusCode.notFound)
        assert(HTTPStatusCode.notFound == 404)

        assert(401 != HTTPStatusCode.notFound)
        assert(HTTPStatusCode.notFound != 401)
        
    }

    func testHTTPStatusRangeEquality() {
        
        assert(HTTPStatusCodeRange.informational.contains(HTTPStatusCode.continue))

        assert(HTTPStatusCodeRange.ok.contains(HTTPStatusCode.ok))

        assert(HTTPStatusCodeRange.redirect.contains(HTTPStatusCode.multipleChoices))
        
        assert(HTTPStatusCodeRange.invalidRequest.contains(HTTPStatusCode.badRequest))

        assert(HTTPStatusCodeRange.serverError.contains(HTTPStatusCode.internalServerError))

    }
    
}
