//
//  File.swift
//  
//
//  Created by ERM on 20/04/2022.
//
import Foundation
import Combine
import ObjectMapper

enum APIEnvironment: String {
    case Dev
    case Staging
    case Production
    case DevProd
    // MARK: portalURL
    
    public var portalURL: String {
        switch self {
        case .Dev: return "http://portal.ermsystem.com"
        case .Staging, .Production: return "http://portal.ermsystem.com"
        case .DevProd: return "http://portal.ermsystem.com"
        }
    }
    
    public var googleMapApiKey: String{
        switch self {
        case .Dev: return "AIzaSyCa2d7UZAY8G4OWFVMRHq5pfbWCB2Ygyso"
        case .Staging, .Production: return "AIzaSyAPZcBgZ2onIJ8jYjh2QWkA50Jwb0GU2jE"
        case .DevProd: return "AIzaSyAPZcBgZ2onIJ8jYjh2QWkA50Jwb0GU2jE"
        }
    }
    //    public var azureSettings: AzureSettings {
    //        switch self {
    //        case .Dev: return AzureSettings(hubKey: "AbGFvtxJeFLaXcfKqLfDrNwNiD1qiDJfFKtqnIqW02o=",
    //                                        hubKeyName: "DefaultListenSharedAccessSignature",
    //                                        hubName: "dev",
    //                                        hubNamespace: "erm-hub")
    //        case .Staging, .Production:    return AzureSettings(hubKey: "pnDahsu96E2N5rAF1+GcqyT96oFgM0N2AcwRQIqtQic=",
    //                                                            hubKeyName: "DefaultListenSharedAccessSignature",
    //                                                            hubName: "prod",
    //                                                            hubNamespace: "erm-hub")
    //        case .DevProd:  return AzureSettings(hubKey: "pnDahsu96E2N5rAF1+GcqyT96oFgM0N2AcwRQIqtQic=",
    //                                             hubKeyName: "DefaultListenSharedAccessSignature",
    //                                             hubName: "prod",
    //                                             hubNamespace: "erm-hub")
    //        }
    //    }
    
    // MARK: API ServiceURL
    
    public var serviceURL: String {
        switch self {
        case .Dev: return "http://api.ermservice.com"
        case .Staging, .Production: return "https://api.ermservice.com"
        case .DevProd:  return "https://api.ermservice.com"
        }
    }
    
    //    public var serviceURL: String {
    //        switch self {
    //        case .Dev: return "https://ermsystem-app-portal-api-test.azurewebsites.net"
    //        case .Staging, .Production: return "https://ermsystem-app-portal-api-test.azurewebsites.net"
    //        case .DevProd:  return "https://ermsystem-app-portal-api-test.azurewebsites.net"
    //        }
    //    }
    
    static let current: APIEnvironment = {
        if let configuration = Bundle.main.object(forInfoDictionaryKey: "Configuration") as? String {
            if configuration.contains("Debug") {
                return .Dev
            } else if configuration.contains("Staging") {
                return .Staging
            }
        }
        return .Production
    }()
}

public enum RegexFormat: String {
    case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    case phone = "^[0-9+]{0,1}+[0-9]{5,16}$"
}

public extension String {
    func isValid(with regex: RegexFormat) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", regex.rawValue).evaluate(with: self)
    }
}


public extension String {
    var isEmail: Bool { return isValid(with: .email) }
    var isPhone: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    var isHttpURL: Bool {
        let value = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.hasPrefix("http:") || value.hasPrefix("https:")
    }
    
    var isFileURL: Bool { self.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("file:") }
}


extension String {
    var fullUrl: String {
        if isHttpURL { return self }
        else if !self.isEmpty { return APIEnvironment.current.serviceURL + self }
        else { return "" } // Case: url is empty
    }
}

public protocol IValidableObject {
    var label: String { get }
    var isValid: Bool { get }
}

// MARK: IOptionInfoObservable

public protocol IOptionInfoObservable: IValidableObject {
    associatedtype T
    var value: T { get }
    var valuePublished: Published<T> { get }
    var valuePublisher: Published<T>.Publisher { get }
}

open class OptionInfoObservable<T>: IOptionInfoObservable, ObservableObject, Identifiable, CustomStringConvertible {
    public typealias T = T
    public var label: String
    public var isValid: Bool { fatalError("Must overriden in subclasses.") }

    @Published public var value: T
    public var valuePublished: Published<T> { _value }
    public var valuePublisher: Published<T>.Publisher { $value }

    init(label: String = "", value: T) {
        self.label = label
        self.value = value
    }

    public var description: String { return "" }
}

public final class StringObservable: OptionInfoObservable<String> {
    override public var isValid: Bool { !value.isEmpty }
    override public var description: String { return value }
}

public final class HyperlinkStringObservable: OptionInfoObservable<String> {
    override public var isValid: Bool { !value.isEmpty || link.isValid }
    override public var description: String { return value }
    public let link: StringObservable
    
    init(label: String = "", value: String, link: StringObservable) {
        self.link = link
        self.link.value = link.value.fullUrl
        super.init(label: label, value: value)
    }
}

public final class BoolObservable: OptionInfoObservable<Bool> {
    override public var isValid: Bool { value }
    override public var description: String { return value.description }
}

public final class IntObservable: OptionInfoObservable<Int> {
    override public var isValid: Bool { value != 0 }
    override public var description: String { return value.description }
}

public final class Int64Observable: OptionInfoObservable<Int64> {
    override public var isValid: Bool { value != 0 }
    override public var description: String { return value.description }
}

open class ArrayObservable<T>: OptionInfoObservable<[T]> {
    override public var isValid: Bool { !value.isEmpty }
    override public var description: String { return value.description }
}

public final class StringCollectionObservable: ArrayObservable<String> {}

public final class IntCollectionObservable: ArrayObservable<Int> {}

// MARK: IViewModel

public typealias EventType = Hashable & CustomStringConvertible
public protocol IViewModel {
    /// event type
    associatedtype T: EventType
    /**
     Register all methods to bind to all methods within the class or UI components
     */
    func bind()
    func emit(_ event: T)
}

// MARK: ViewModel

open class ViewModel<T: EventType>: IViewModel {
    public static var defaultEvent: String { String(describing: type(of: self)) }
    public lazy var disposers = [String: AnyCancellable]()
    private lazy var eventEmitter = PassthroughSubject<T, Never>()
    open var supportedNotifications: [Notification.Name] { return [] }
    
    // emit error message
    @Published var errorMessage: String = ""
    public var events: AnyPublisher<T, Never> {
        eventEmitter.share().eraseToAnyPublisher()
    }
    
    init() {
        initialize()
        registerNotifications()
        bind()
    }

    fileprivate func registerNotifications() {
        guard !supportedNotifications.isEmpty else { return }
        Notificator.addUniqueObserver(self, selector: #selector(handleNotification(_:)), for: supportedNotifications)
    }
    
    fileprivate func unRegisterNotifications() {
        guard !supportedNotifications.isEmpty else { return }
        supportedNotifications.forEach {
            Notificator.removeObserver(self, name: $0)
        }
    }
    
    @objc func handleNotification(_ notification: Notification) {
        guard let type = notification.userInfo?[Notification.userInfoKeys.object] as? T else { return }
        handle(event: type)
    }
    
    open func initialize() {}
    
    open func bind() {
        disposers["event"] = eventEmitter.sink(receiveValue: { [weak self] type in
            self?.handle(event: type)
        })
    }

    open func handle(event: T) {}
    open func emit(_ event: T) {
        debugPrint("check even\(event)")
        eventEmitter.send(event)
    }
    
    deinit {
        unRegisterNotifications()
    }
}

open class BaseViewModel: ViewModel<String> {}

// MARK: Notification Event Supported

extension NotificationManager {
    public func send<T: EventType>(event: T, forName name: Notification.Name) {
        post(to: name, with: event, onMainThread: false)
    }
}
