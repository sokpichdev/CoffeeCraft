//
//  NotificationView.swift
//  NotificationApp
//
//  Created by Sok Pich on 4/17/25.
//

import SwiftUI
import Firebase
import FirebaseMessaging

struct NotificationView: View {
    @Environment(\.scenePhase) var scenePhase
    @State private var fcmToken: String = "Fetching..."
    @State private var notifications: [AppNotification] = []
    @State private var showList = false


    var body: some View {
        VStack(spacing: 20) {
            Text("Local Notification Demo").font(.title)
            
            Button("Request Permission") {
                NotificationManager.instance.requestAuthorization()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("View Notifications (\(notifications.filter { !$0.isRead }.count))") {
                showList = true
            }
            .padding()
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(10)
            Button("Simulate Notification") {
                receiveNotification(title: "Test Title", body: "This is a simulated notification.")
            }

            Button("Send Notification in 5s") {
                NotificationManager.instance.scheduleNotification()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Button("Schedule 3 Notifications (Every 5s)") {
                NotificationManager.instance.scheduleMultipleNotifications()
            }
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(10)

            VStack(spacing: 20) {
                Text("FCM Token:")
                    .font(.headline)
                Text(fcmToken)
                    .font(.footnote)
                    .padding()
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = fcmToken
                        }) {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                    }

                Button("Get Token Again") {
                    fetchToken()
                }
            }
        }
        .padding()
        .onAppear {
            UNUserNotificationCenter.current().delegate = UIApplication.shared.delegate as? UNUserNotificationCenterDelegate
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    fetchToken()
                }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }
        .sheet(isPresented: $showList) {
            NavigationView {
                NotificationListView(notifications: $notifications)
            }
        }
    }

    func fetchToken() {
        Messaging.messaging().token { token, error in
            if let token = token {
                fcmToken = token
                print("✅ Manual fetch FCM token: \(token)")
            } else if let error = error {
                fcmToken = "Error: \(error.localizedDescription)"
                print("❌ Error fetching FCM token: \(error)")
            }
        }
    }
    func receiveNotification(title: String, body: String) {
        let newNotif = AppNotification(title: title, body: body)
        notifications.append(newNotif)
        UIApplication.shared.applicationIconBadgeNumber += 1
    }
}

struct AppNotification: Identifiable {
    let id = UUID()
    let title: String
    let body: String
    var isRead: Bool = false
}

struct NotificationListView: View {
    @Binding var notifications: [AppNotification]

    var body: some View {
        List {
            ForEach(notifications.indices, id: \.self) { index in
                let notification = notifications[index]
                HStack {
                    VStack(alignment: .leading) {
                        Text(notification.title).bold()
                        Text(notification.body).font(.subheadline)
                    }
                    Spacer()
                    if !notification.isRead {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                    }
                }
                .onTapGesture {
                    notifications[index].isRead = true
                    updateBadge()
                }
            }
        }
        .navigationTitle("Notifications")
    }

    func updateBadge() {
        let unreadCount = notifications.filter { !$0.isRead }.count
        UIApplication.shared.applicationIconBadgeNumber = unreadCount
    }
}
