
import Foundation

// MARK: Safe cast type

public func castTo<T>(_ object: Any?, default: T) -> T {
    return object as? T ?? `default`
}

public func toString(_ object: Any?) -> String {
    return castTo(object, default: "")
}

public func toInt(_ object: Any?) -> Int {
    return castTo(object, default: -1)
}

public func toFloat(_ object: Any?) -> Float {
    return castTo(object, default: -1)
}

public func toDouble(_ object: Any?) -> Double {
    return castTo(object, default: -1)
}

public func toBool(_ object: Any?) -> Bool {
    return castTo(object, default: false)
}

// MARK: JSONSerialization

extension JSONSerialization {
    public static func toJsonString<T>(_ object: T) -> String {
        let options = JSONSerialization.WritingOptions.prettyPrinted
        if JSONSerialization.isValidJSONObject(object) {
            if let data = try? JSONSerialization.data(withJSONObject: object, options: options) {
                if let string = String(data: data, encoding: .utf8) {
                    return string
                }
            }
        }
        return ""
    }
}

public extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    var toJsonString: String {
        return JSONSerialization.toJsonString(self)
    }
}

public extension Array where Element == [String: Any] {
    var toJsonString: String {
        return JSONSerialization.toJsonString(self)
    }
}
