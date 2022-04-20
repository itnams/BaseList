//
//  File.swift
//  
//
//  Created by ERM on 20/04/2022.
//

import Combine
import UIKit
import UserNotifications

/**
 NotificationManager: a class to manage all notification types includes: local/remote or notification center events
 */
public class NotificationManager: NSObject {
    static let shared = NotificationManager()
    public lazy var disposers = [String: AnyCancellable]()

    fileprivate var lastDeviceToken: String = ""
//    fileprivate var registrationService: AzureAPNRegistrationService?

    fileprivate lazy var eventEmitter = PassthroughSubject<NotificationEvent, Never>()
    public lazy var events: AnyPublisher<NotificationEvent, Never> = {
        eventEmitter.share().eraseToAnyPublisher()
    }()

    public func emit(_ event: NotificationEvent) {
        eventEmitter.send(event)
    }
}

public let Notificator = NotificationManager.shared

// MARK: Notification User Delegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    func with(application: UIApplication) {
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // For iOS 10 display notification (sent via APNS)
        /// check permissionn
        checkPermissions(application) { _ in }
        UNUserNotificationCenter.current().delegate = self
    }


    func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {
        debugPrint("[Notification]: \(error.localizedDescription)")
    }

    func didReceiveRemoteNotification(
        userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        let userInfo = userInfo as? [String: Any] ?? [:]
        handleNotification(userInfo, didTap: false)
    }

    // Receive displayed notifications for iOS 10 devices.
    // Handle notification from internal app
    public func userNotificationCenter(_: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        /// convert AnyHashable to String
        let userInfo = notification.request.content.userInfo as? [String: Any] ?? [:]
        handleNotification(userInfo)

        /// show notification in foreground
        completionHandler([.banner, .list, .sound, .badge])
    }

    // Handle notification from external app
    public func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        /// convert AnyHashable to String
        let userInfo = response.notification.request.content.userInfo as? [String: Any] ?? [:]
        handleNotification(userInfo, didTap: true)
        completionHandler()
    }
}

// MARK: Permissions

extension NotificationManager {
    fileprivate func checkPermissions(_ application: UIApplication, _ completion: @escaping (Bool) -> Void) {
        /// check permission
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { [weak self] settings in
            switch settings.authorizationStatus {
            case .authorized:
                debugPrint("Notification Authorized!! Go Ahead Buddy")
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                    completion(true)
                }

            case .notDetermined:
                self?.requestPermissions { _, error in
                    if let error = error {
                        debugPrint("[Notificaiton]: \(error.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            application.registerForRemoteNotifications()
                        }
                        debugPrint("Notification Authorized!! Go Ahead Buddy")
                    }
                }
                completion(false)

            case .denied, .ephemeral, .provisional:
                self?.openAppSettings()
                completion(false)

            @unknown default: fatalError()
            }
        }
    }

    fileprivate func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }

    fileprivate func requestPermissions(_ completion: @escaping (Bool, Error?) -> Void) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: completion
        )
    }
}
