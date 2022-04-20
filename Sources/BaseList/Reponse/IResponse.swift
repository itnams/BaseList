
import Alamofire
import Combine
import Foundation

/**
 Object is received after execute IRequest via IHttpClient
 */
public protocol IResponse {
    var success: Bool { get }
    var message: String { get }
    var messages: [String] { get }
    var error: RequestError { get }
    init(_ response: AFDataResponse<Any>?)

    /// special instances for exception cases
    static func error(with error: RequestError) -> Self
    static func unknown() -> Self
}

public protocol IApiLinks {
    var nextPage: String { get }
    var previousPage: String { get }
}

/**
 Base struct of IResponse
 */
open class Response: IResponse {
    // public var isSuccess: Bool { success && serverError == .success }
    public var success: Bool = false /// "success" key
    public var messages: [String] = []
    public var message: String = ""
    public var error: RequestError = .undefined
    internal var serverError: ServerError = .undefined

    public required init(_ response: AFDataResponse<Any>? = nil) {
        switch response?.result {
        /// parse JSON to get information here
        case let .success(value):
//            debugPrint("[Response]: \(value)")
            parseJson(value)
//            if !checkErrorClientResponse(response) {
//                parseJson(value)
//            } else {
//                self.success = false
//            }
        /// handle network error
        case let .failure(error):
//            debugPrint(".failure")
            parseError(error)

        default: break
        }
    }

    public required init(with error: RequestError) {
        self.error = error
    }

    /// template methods for parsing JSON data
    open func parseJson(_ json: Any) {}

    /// template methods for parsing error
    open func parseError(_ error: AFError) {
        #if DEBUG
            self.error = .client(error.errorDescription ?? "")
        #else
            self.error = .undefined
        #endif
    }

    /// special instances for exception cases
    public static func error(with error: RequestError) -> Self {
        return self.init(with: error)
    }

    public static func unknown() -> Self {
        return self.init()
    }

//    private func checkErrorClientResponse(_ response: AFDataResponse<Any>?) -> Bool {
//        do {
//            guard let data = response?.data else {
//                return true
//            }
//            let errorResponse = try JSONDecoder().decode(ErrorClientResponse.self, from: data)
//
//            if let isSuccess = errorResponse.success  {
//                if !isSuccess {
//                    errorResponse.messages?.forEach { message in
//                        messages.append(message)
//                    }
//                    error = RequestError.client(errorResponse.message ?? "Unknown")
//                    return true
//                }
//            }
//            return false
//            // TODO: handle "message" Key
//
//        } catch {
//            return true
//        }
//    }
}

// MARK: - ErrorClientResponse

//
// struct ErrorClientResponse: Codable {
//    let code: String?
//    let success: Bool?
//    let message: String?
//    let messages: [String]?
//
//    enum CodingKeys: String, CodingKey {
//        case code
//        case success
//        case message
//        case messages
//    }
// }
