//
//  ContentView.swift
//  Project Pegasus
//
//  Created by Lorenzo Vecchio on 28/10/23.
//

import SwiftUI
import SwiftData
// import FamilyControls

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query let categories: [Category]
    @Query let sessions: [Session]
    @StateObject var timerManager = TimerManager()
    
    var body: some View {
        VStack {
            
            Home().onAppear {
                var isFirstLoad: Bool {
                    get {
                        UserDefaults.standard.bool(forKey: "isFirstLoad")
                    }
                    set {
                        UserDefaults.standard.set(newValue, forKey: "isFirstLoad")
                    }
                }
                if !isFirstLoad {
                    initApp()
                } else {
                    // check if sessions where left without end date
                    regularOperations()
                }
            }
        }
    }
    
    func regularOperations() {
        let center = UNUserNotificationCenter.current()
        center.getDeliveredNotifications { notifications in
            for notification in notifications {
                if let userInfo = notification.request.content.userInfo as? [String: Any],
                   let isTimer = userInfo["isTimer"] as? Bool,
                   isTimer
                {
                    let identifier = notification.request.identifier
                    // let fetchDescriptor = FetchDescriptor<Session>()
                    do {
                        if let session = sessions.first(where: { $0.id == identifier }) {
                            if session.stopDate == nil {
                                session.stopDate = session.startDate.addingTimeInterval(session.timeGoal)
                                try context.save()
                            }
                        }
                    } catch {
                        print("Error accessing context: \(error)")
                        return
                    }
                }
            }
        }
    }
    
    func initApp() {
        var isFirstLoad: Bool {
            get {
                UserDefaults.standard.bool(forKey: "isFirstLoad")
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "isFirstLoad")
            }
        }
        let timerManager = TimerManager()
        timerManager.requestNotificationPermission()
//        let authCenter = AuthorizationCenter.shared
//        Task {
//            do {
//                try await authCenter.requestAuthorization(for: .individual)
//            } catch {
//                handle the error
//            }
//        }
        let testUser: User = User(nome: "Giorgio")
        let category1: Category = Category(name: "studio", color: "EC8E14")
        let category2: Category = Category(name: "lavoro", color: "F6DE00")
        let category3: Category = Category(name: "detox", color: "67CD67")
        let category4: Category = Category(name: "sport", color: "01A0E2")
        context.insert(testUser)
        context.insert(category1)
        context.insert(category2)
        context.insert(category3)
        context.insert(category4)
        
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        
        print(categories.count)
        
        //let twoHoursAgo: Date = Date().addingTimeInterval(-2 * 60 * 60)
        //let oneHoursAgo: Date = Date().addingTimeInterval(-1 * 60 * 60)
        //let session1: Session = Session(category: categories[0], startDate: twoHoursAgo, stopDate: oneHoursAgo, timeGoal: (1.5 * 60 * 60))
        //let session2: Session = Session(category: categories[1], startDate: twoHoursAgo,stopDate: oneHoursAgo, timeGoal: (1.3 * 60 * 60))
        //context.insert(session1)
        //context.insert(session2)
        //do {
        //    try context.save()
        //    print("sessioni salvate")
        //} catch {
        //    print("Error saving context: \(error)")
        //}
        
        isFirstLoad = true
    }
}

#Preview {
    ContentView()
}
