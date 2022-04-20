import Foundation

public enum ServerError: String {
    case undefined = ""
    case success = "SUCCESS"
    case error = "ERROR"
    case notFound = "NOT_FOUND"
    case notAuthorized = "NOT_AUTHORIZED"
    case dataInUse = "DATA_IN_USE"
    case noPermission = "NO_PERMISSION"
    case processing = "PROCESSING"
    case warning = "WARNING"
    case existed = "EXISTED"
    
    public var description: String {
        if self == .undefined {
            return "Something went wrong. (These are rare.)"
        }
        return rawValue
    }
}

public enum RequestError: Error, CustomStringConvertible {
    case undefined
    case generic(String)
    case server(ServerError, String)
    case client(String)
    
    public var description: String {
        switch self {
        case .server(_, let message): return message
        case .client(let message): return message
        case .generic(let message): return message
        default: return ""
        }
    }
}
