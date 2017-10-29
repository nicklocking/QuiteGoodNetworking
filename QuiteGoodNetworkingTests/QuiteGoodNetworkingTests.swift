import XCTest
import Swifter

class QuiteGoodNetworking_Tests: XCTestCase {
    
    var server = HTTPServer()
    
    override func setUp() {
        super.setUp()
        
        server.start()
    }
    
    override func tearDown() {
        
        super.tearDown()
        
        server.stop()
    }
    
    func testExample() {
        
    }
    
    func testPerformanceExample() {
        
        //        self.measure {
        //            // Put the code you want to measure the time of here.
        //        }
    }
    
}

