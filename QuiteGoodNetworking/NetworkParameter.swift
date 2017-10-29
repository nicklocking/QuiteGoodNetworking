import Foundation

// Protocol to declare that a type can be expressed as a parameter for a
// network request.
public protocol NetworkParameter {
    
}

// These types can be expressed as network parameters
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
