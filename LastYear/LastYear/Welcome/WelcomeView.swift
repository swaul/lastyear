//
//  WelcomeView.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import SwiftUI

struct WelcomeView: View {

    @State var showRegistration: Bool = false
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            VStack {
                Spacer()
                LogoView(size: 35)
                Spacer()
                Image("rocket")
                    .resizable()
                    .foregroundColor(.white)
                    .frame(width: 200, height: 200, alignment: .center)
                Spacer()
                Button {
                    showRegistration = true
                } label: {
                    Text("Start Your Journey")
                        .font(Font.custom("Poppins-Bold", size: 18))
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color.black)
                        .background(Color.white)
                        .cornerRadius(8)
                }
                Spacer()
            }
            .padding(16)
            .sheet(isPresented: $showRegistration) {
                ChoseAuthView()
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
