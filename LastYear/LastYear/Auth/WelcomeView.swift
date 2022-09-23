//
//  WelcomeView.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        ZStack {
            Color("backgroundColor")
            VStack {
                Spacer()
                HStack(spacing: 0) {
                    Text("About")
                        .font(Font.custom("Poppins-Bold", size: 35))
                        .foregroundColor(.white)
                    Text("Last")
                        .font(Font.custom("Poppins-Bold", size: 35))
                        .foregroundColor(Color("primary"))
                    Text("Year")
                        .font(Font.custom("Poppins-Bold", size: 35))
                        .foregroundColor(.white)
                }
                Spacer()
                Image(systemName: "clock")
                    .resizable()
                    .foregroundColor(.white)
                    .frame(width: 200, height: 200, alignment: .center)
                Spacer()
                Button {
                    print("hey")
                } label: {
                    Text("Start Your Journey")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color.black)
                        .background(Color.white)
                        .cornerRadius(10)
                }
                Spacer()
            }
            .padding(16)
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
