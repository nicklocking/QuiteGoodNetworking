import Foundation

public typealias NetworkParameterDictionary = [String: NetworkParameter?]

protocol QueryParametersConversion {
    
    func queryParametersString() -> String
    
}

extension Dictionary: QueryParametersConversion {
    
    func queryParametersString() -> String {

        let queryParameterStrings: [String] = self.flatMap {"\($0)=\($1)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)}

        return queryParameterStrings.joined(separator: "&")

    }
    
}










//extension Dictionary {
//
//    func withoutNilValues() -> [Key: Any] {
//
//        var cleaned = Dictionary<Key, Any>()
//
//        for (key, value) in self {
//
//            if
//                let optionalParameter = value as? OptionalProtocol,
//                (
//                    !optionalParameter.isSome() // Sadly, nil can still slip through when dynamic JSON comes in; check for a nil value here
//                        || (optionalParameter.unwrap() as? NSNull != nil) // "is" doesn't work. Verifies protocol conformance.  We can safely unwrap if isSome() is true
//                )
//            {
//                // value is nil or NSNull, so don't include it
//                continue
//            }
//
//            if let localValue = (value as Any?) {
//                cleaned[key] = localValue
//            }
//        }
//
//        return cleaned
//    }
//
//}

//import Foundation
//
//extension Array {
//    func makeArrayNetworkEncodable() -> [NetworkParameter]? {
//        return flatMap({ (value) -> NetworkParameter? in
//            return convertToNetworkParameter(value: value)
//        })
//    }
//}

extension Dictionary {
    
    //    func convertToNetworkDictionary() -> NetworkDictionary? {
    //        var converted = NetworkDictionary()
    //        for (key, value) in self {
    //            guard let keyString = key as? String else {
    //                assertionFailure()
    //                continue
    //            }
    //
    //            converted[keyString] = convertToNetworkParameter(value: value)
    //        }
    //        if converted.keys.count == 0 {
    //            return nil
    //        }
    //        return converted
    //    }
    //
    
}

//
//extension Array where Element: NetworkParameter {}
//extension Dictionary where Key: ExpressibleByStringLiteral, Value: NetworkParameter {}
//
///*
// Converts any type to a NetworkParameter if possible, or nil.
// */
//func convertToNetworkParameter(value: AnyObject) -> NetworkParameter? {
//
//    /** IMPORTANT: Collections or anything that nests / wraps a NetworkParameter needs to be tried before attempting a cast to NetworkParameter **/
//    if let arr = value as? [Any] {
//        guard let convertedArray = arr.makeArrayNetworkEncodable() else {
//            assertionFailure()
//            return NSNull()
//        }
//        return convertedArray
//    } else if let dict = value as? [AnyHashable: Any] {
//        guard let convertedDictionary = dict.convertToNetworkDictionary() else {
//            assertionFailure()
//            return NSNull()
//        }
//        return convertedDictionary
//    } else if let convertedParameter = value as? NetworkParameter {
//        return convertedParameter
//    } else if
//        let optionalParameter = value as? OptionalProtocol,
//        (
//            !optionalParameter.isSome() // Sadly, nil can still slip through when dynamic JSON comes in; check for a nil value here
//                || (optionalParameter.unwrap() as? NetworkParameter != nil) // "is" doesn't work. Verifies protocol conformance.  We can safely unwrap if isSome() is true
//        )
//    {
//        if optionalParameter.isSome() {
//            return optionalParameter.unwrap() as! NetworkParameter
//        } else {
//            return NSNull()
//        }
//    } else {
//        assertionFailure()
//        return NSNull()
//    }
//}
//
//import Foundation
//
//// This is a way to get the wrapped type of an optional when the type is not known at compile time
//protocol OptionalProtocol {
//    func isSome() -> Bool
//    func wrappedType() -> Any.Type
//    func unwrap() -> Any
//}
//
//extension Optional: OptionalProtocol {
//
//    func isSome() -> Bool {
//        switch self {
//        case .none: return false
//        case .some: return true
//        }
//    }
//
//    func unwrap() -> Any {
//        switch self {
//        // If a nil is unwrapped it will crash!
//        case .none: preconditionFailure("nil unwrap")
//        case .some(let unwrapped): return unwrapped
//        }
//    }
//
//    func wrappedType() -> Any.Type {
//        return Wrapped.self
//    }
//}



