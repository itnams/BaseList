
import Foundation

public enum NotificationKey: String {
    case aps = "aps"
    case extraInfo = "extraInfo"
    case type = "type"
    case id = "id"
    case message = ""
}

enum NotificationType: String {
    case Unknown = "unknown"
    case Lead = "lead"
}

public enum NotificationEvent {
    case leadDetail(Int)
}

extension Dictionary where Key == String {
    func value(for key: NotificationKey) -> Value? {
        return self[key.rawValue]
    }
}

public struct RemoteNotificationPayload {}

extension NotificationManager {
    func handleNotification(_ userInfo: [String: Any], didTap: Bool = false) {
        debugPrint("userInfo: \(userInfo.toJsonString)")
        guard let aps = userInfo[NotificationKey.aps.rawValue] as? [AnyHashable: Any],
              let extraInfo = aps[NotificationKey.extraInfo.rawValue] as? [AnyHashable: Any],
              let type = extraInfo[NotificationKey.type.rawValue] as? String
        else {
            return
        }

        if let type = NotificationType(rawValue: type) {
            switch type {
            case .Lead:
                debugPrint("Lead Detail Notification")
                if let id = extraInfo[NotificationKey.id.rawValue] as? String {
                    if didTap {
                        debugPrint("Send lead detail Id: \(id)")
                        emit(.leadDetail(Int(id) ?? -1))
                    }
                }
                break

            default:
                debugPrint("Type: \(type)")
            }
        }
    }
}
