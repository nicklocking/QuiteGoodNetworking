import Foundation
import CoreGraphics

/**
 Protocol to declare that a type can be expressed as a parameter for a network request.
 Any type that is declared to conform to this protocol should be convertible to an HTTP
 parameter.
 */
public protocol NetworkParameter {
    
}

extension Int: NetworkParameter {}
extension Float: NetworkParameter {}
extension Double: NetworkParameter {}
extension Bool: NetworkParameter {}
extension String: NetworkParameter {}
extension Date: NetworkParameter {}
extension URL: NetworkParameter {}
extension NSString: NetworkParameter {}
extension NSDate: NetworkParameter {}
extension NSNumber: NetworkParameter {}
extension NSNull: NetworkParameter {}
extension CGFloat: NetworkParameter {}
extension NSURL: NetworkParameter {}
extension Array: NetworkParameter {}
extension Dictionary: NetworkParameter {}
extension UInt64: NetworkParameter {}
