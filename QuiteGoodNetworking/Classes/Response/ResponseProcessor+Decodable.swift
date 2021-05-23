import Foundation

public enum QGNError: Swift.Error {
  case imageMapping(ResponseProcessor)
  case jsonMapping(ResponseProcessor)
  case stringMapping(ResponseProcessor)
  case objectMapping(Swift.Error, ResponseProcessor)
  case encodableMapping(Swift.Error)
  case statusCode(ResponseProcessor)
  case underlying(Swift.Error, ResponseProcessor?)
  case requestMapping(String)
  case parameterEncoding(Swift.Error)
}

public extension ResponseProcessor {
  
  /// Maps data received from the signal into a JSON object.
  ///
  /// - parameter failsOnEmptyData: A Boolean value determining
  /// whether the mapping should fail if the data is empty.
  func mapJSON(failsOnEmptyData: Bool = true) throws -> Any {
    do {
      return try JSONSerialization.jsonObject(with: responseData(), options: .allowFragments)
    } catch {
      if responseData().count < 1 && !failsOnEmptyData {
        return NSNull()
      }
      throw QGNError.jsonMapping(self)
    }
  }
  
  /// Maps data received from the signal into a Decodable object.
  ///
  /// - parameter atKeyPath: Optional key path at which to parse object.
  /// - parameter using: A `JSONDecoder` instance which is used to decode data to an object.
  func map<D: Decodable>(_ type: D.Type, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true) throws -> D {
    let serializeToData: (Any) throws -> Data? = { (jsonObject) in
      guard JSONSerialization.isValidJSONObject(jsonObject) else {
        return nil
      }
      do {
        return try JSONSerialization.data(withJSONObject: jsonObject)
      } catch {
        throw QGNError.jsonMapping(self)
      }
    }
    let jsonData: Data
    keyPathCheck: if let keyPath = keyPath {
      guard let jsonObject = (try mapJSON(failsOnEmptyData: failsOnEmptyData) as? NSDictionary)?.value(forKeyPath: keyPath) else {
        if failsOnEmptyData {
          throw QGNError.jsonMapping(self)
        } else {
          jsonData = responseData()
          break keyPathCheck
        }
      }
      
      if let data = try serializeToData(jsonObject) {
        jsonData = data
      } else {
        let wrappedJsonObject = ["value": jsonObject]
        let wrappedJsonData: Data
        if let data = try serializeToData(wrappedJsonObject) {
          wrappedJsonData = data
        } else {
          throw QGNError.jsonMapping(self)
        }
        do {
          return try decoder.decode(DecodableWrapper<D>.self, from: wrappedJsonData).value
        } catch let error {
          throw QGNError.objectMapping(error, self)
        }
      }
    } else {
      jsonData = responseData()
    }
    do {
      if jsonData.count < 1 && !failsOnEmptyData {
        if let emptyJSONObjectData = "{}".data(using: .utf8), let emptyDecodableValue = try? decoder.decode(D.self, from: emptyJSONObjectData) {
          return emptyDecodableValue
        } else if let emptyJSONArrayData = "[{}]".data(using: .utf8), let emptyDecodableValue = try? decoder.decode(D.self, from: emptyJSONArrayData) {
          return emptyDecodableValue
        }
      }
      return try decoder.decode(D.self, from: jsonData)
    } catch let error {
      throw QGNError.objectMapping(error, self)
    }
  }
  
}

private struct DecodableWrapper<T: Decodable>: Decodable {
  let value: T
}

public protocol DecodableClassFamily : Decodable {
    associatedtype BaseType : Decodable
    static var discriminator: Discriminator { get }

    func getType() -> BaseType.Type
}

public enum Discriminator : String, CodingKey {
    case object
}

public extension KeyedDecodingContainer {
  
  func decodeHeterogeneousArray<F : DecodableClassFamily>(family: F.Type, forKey key: K) throws -> [F.BaseType] {
    
    var container = try nestedUnkeyedContainer(forKey: key)
    var containerCopy = container
    var items: [F.BaseType] = []
    while !container.isAtEnd {
      
      let typeContainer = try container.nestedContainer(keyedBy: Discriminator.self)
      do {
        let family = try typeContainer.decode(F.self, forKey: F.discriminator)
        let type = family.getType()
        // decode type
        let item = try containerCopy.decode(type)
        items.append(item)
      } catch let e as DecodingError {
        switch e {
        case .dataCorrupted(let context):
          if context.codingPath.last?.stringValue == F.discriminator.stringValue {
            //Needed to get container currentIndex incremented
            _ = try containerCopy.decode(F.BaseType.self)
          } else {
            throw e
          }
        default: throw e
        }
      }
    }
    return items
  }
  
}

public extension UnkeyedDecodingContainer {
  
  mutating func decodeHeterogeneousArray<F : DecodableClassFamily>(family: F.Type) throws -> [F.BaseType] {
    var container = self
    var containerCopy = container
    var items: [F.BaseType] = []
    while !container.isAtEnd {
      
      let typeContainer = try container.nestedContainer(keyedBy: Discriminator.self)
      do {
        let family = try typeContainer.decode(F.self, forKey: F.discriminator)
        let type = family.getType()
        // decode type
        let item = try containerCopy.decode(type)
        items.append(item)
      } catch let e as DecodingError {
        switch e {
        case .dataCorrupted(let context):
          if context.codingPath.last?.stringValue == F.discriminator.stringValue {
            //Needed to get container currentIndex incremented
            _ = try containerCopy.decode(F.BaseType.self)
          } else {
            throw e
          }
        default: throw e
        }
      }
    }
    return items
  }
  
}

public struct JsonContainer: Decodable {
  public let value: Any

  public init(from decoder: Decoder) throws {
    if let keyedContainer = try? decoder.container(keyedBy: Key.self) {
      var dictionary = [String: Any]()
      for key in keyedContainer.allKeys {
        if let value = try? keyedContainer.decode(Bool.self, forKey: key) {
          // Wrapping numeric and boolean types in `NSNumber` is important, so `as? Int64` or `as? Float` casts will work
          dictionary[key.stringValue] = NSNumber(value: value)
        } else if let value = try? keyedContainer.decode(Int64.self, forKey: key) {
          dictionary[key.stringValue] = NSNumber(value: value)
        } else if let value = try? keyedContainer.decode(Double.self, forKey: key) {
          dictionary[key.stringValue] = NSNumber(value: value)
        } else if let value = try? keyedContainer.decode(String.self, forKey: key) {
          dictionary[key.stringValue] = value
        } else if (try? keyedContainer.decodeNil(forKey: key)) ?? false {
          // NOP
        } else if let value = try? keyedContainer.decode(JsonContainer.self, forKey: key) {
          dictionary[key.stringValue] = value.value
        } else {
          throw DecodingError.dataCorruptedError(forKey: key, in: keyedContainer, debugDescription: "Unexpected value for \(key.stringValue) key")
        }
      }
      value = dictionary
    } else if var unkeyedContainer = try? decoder.unkeyedContainer() {
      var array = [Any]()
      while !unkeyedContainer.isAtEnd {
        let container = try unkeyedContainer.decode(JsonContainer.self)
        array.append(container.value)
      }
      value = array
    } else if let singleValueContainer = try? decoder.singleValueContainer() {
      if let value = try? singleValueContainer.decode(Bool.self) {
        self.value = NSNumber(value: value)
      } else if let value = try? singleValueContainer.decode(Int64.self) {
        self.value = NSNumber(value: value)
      } else if let value = try? singleValueContainer.decode(Double.self) {
        self.value = NSNumber(value: value)
      } else if let value = try? singleValueContainer.decode(String.self) {
        self.value = value
      } else if singleValueContainer.decodeNil() {
        value = NSNull()
      } else {
        throw DecodingError.dataCorruptedError(in: singleValueContainer, debugDescription: "Unexpected value")
      }
    } else {
      let context = DecodingError.Context(codingPath: [], debugDescription: "Invalid data format for JSON")
      throw DecodingError.dataCorrupted(context)
    }
  }

  private struct Key: CodingKey {
    var stringValue: String

    init?(stringValue: String) {
      self.stringValue = stringValue
    }

    var intValue: Int?

    init?(intValue: Int) {
      self.init(stringValue: "\(intValue)")
      self.intValue = intValue
    }
  }
}
