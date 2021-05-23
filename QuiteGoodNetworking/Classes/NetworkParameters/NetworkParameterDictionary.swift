import Foundation

/**
 Typealias for a string-indexed dictionary that contains only network-encodable parameters.
 */
public typealias NetworkParameterDictionary = [String: NetworkParameter]

/**
 Convenience protocol to convert a collection to a string for use in HTTP URL queries.
 */
protocol QueryStringParametersStringConversion {
    
    func queryStringParametersString() -> String
    
}

/**
 Implementation of query parameter string conversion for a dictionary.
 
 // where Key: CustomStringConvertible, Value: NetworkParameter
 */
extension Dictionary: QueryStringParametersStringConversion {
    
    func queryStringParametersString() -> String {

        let queryStringParametersStrings: [String] = self.compactMap {"\($0)=\($1)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)}

        return queryStringParametersStrings.joined(separator: "&")

    }
    
}
