//
//  NotificationPermissionView.swift
//  LastYear
//
//  Created by Paul Kühnel on 27.09.22.
//

import SwiftUI

struct NotificationPermissionView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var permissionHandler = PermissionHandler.shared
    
    @State var notiShowing: Bool = false
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            VStack {
                ZStack {
                    Image("stars2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                    VStack {
                        Spacer()
                        VStack {
                            Image(systemName: "arrow.up")
                                .resizable()
                                .foregroundColor(.white)
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 100)
                                .offset(y: notiShowing ? -20 : 0)
                                .animation(Animation.easeInOut.repeatForever(autoreverses: true).speed(0.75), value: notiShowing)
                            Text("Looks like this!")
                                .font(Font.custom("Poppins-Bold", size: 20))
                                .foregroundColor(Color.white)
                                .padding(.top)
                        }
                        Spacer()
                        VStack(spacing: -4) {
                            Text("Let us")
                                .font(Font.custom("Poppins-Bold", size: 48))
                                .foregroundColor(Color.white)
                            Text("remind you")
                                .font(Font.custom("Poppins-Bold", size: 48))
                                .foregroundColor(Color("primary"))
                            Text("of your")
                                .font(Font.custom("Poppins-Bold", size: 48))
                                .foregroundColor(Color.white)
                            Text("Memories.")
                                .font(Font.custom("Poppins-Bold", size: 48))
                                .foregroundColor(Color.white)
                        }
                        Spacer()
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                notiShowing = true
                            }
                        }
                    }
                }
            }
            VStack {
                notificationView
                    .offset(x: 0, y: notiShowing ? 0 : -400)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.4), value: notiShowing)
                    .onTapGesture { _ in
                        requestNotiAccess()
                    }
                Spacer()
            }
        }
    }
    
    var notificationView: some View {
        HStack {
            Image("fallback")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 52, height: 52)
                .cornerRadius(10)
            VStack(alignment: .leading) {
                Text("You have 14 pictures to look back on from \(Formatters.dateFormatter.string(from: Date.now))")
                    .font(Font.custom("Poppins-SemiBold", size: 14))
                    .foregroundColor(.black)
                Text("Take a look and share it with your friends!")
                    .font(Font.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.black)
            }
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(20)
    }
    
    func requestNotiAccess() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                DispatchQueue.main.async {
                    PermissionHandler.shared.notDetermined = false
                }
                LocalNotificationCenter.shared.scheduleFirst()
                presentationMode.wrappedValue.dismiss()
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct NotificationPermissionView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPermissionView()
    }
}
