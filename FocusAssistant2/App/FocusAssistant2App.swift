//
//  FocusAssistant2App.swift
//  FocusAssistant2
//
//  Created by Nana Sekyere on 20/09/2025.
//

import SwiftUI
import SwiftData
import Firebase
import FirebaseAuth

@main
struct FocusAssistant2App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            TabBar()
        }
        .modelContainer(sharedModelContainer)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        #if DEBUG
                Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
        #else
                Auth.auth().setAPNSToken(deviceToken, type: .prod)
        #endif
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
        }
    }
}
