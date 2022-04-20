import Foundation

extension Notification.Name {}

extension Notification {
    struct userInfoKeys {
        public static let object = "com.ermsystem.notification.internal.object"
    }
}

extension NotificationManager {
    public func post(to name: Notification.Name, with object: Any? = nil, onMainThread: Bool = false) {
        let userInfo = (object != nil ? [Notification.userInfoKeys.object: object!] : [:])
        if onMainThread {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
            }
        } else {
            DispatchQueue.global(qos: .background).async {
                NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
            }
        }
    }

    public func addUniqueObserver(_ observer: Any, selector: Selector, with name: Notification.Name) {
        debugPrint("Register Notification ----> \(name.rawValue)")

        /// remove previous
        removeObserver(observer, name: name)

        /// add new one
        NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: nil)
    }

    public func addUniqueObserver(_ observer: Any, selector: Selector, for names: [Notification.Name]) {
        for name in names {
            addUniqueObserver(observer, selector: selector, with: name)
        }
    }

    public func removeObserver(_ observer: Any, name: Notification.Name? = nil) {
        if name == nil {
            NotificationCenter.default.removeObserver(observer)
        } else {
            NotificationCenter.default.removeObserver(observer, name: name!, object: nil)
        }
    }
}
