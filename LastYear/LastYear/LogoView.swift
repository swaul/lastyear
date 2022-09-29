//
//  LogoView.swift
//  LastYear
//
//  Created by Paul Kühnel on 29.09.22.
//

import SwiftUI

struct LogoView: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("About")
                .font(Font.custom("Poppins-Bold", size: 35))
                .foregroundColor(.white)
            Text("Last")
                .font(Font.custom("Poppins-Bold", size: 35))
                .foregroundColor(Color("primary"))
            Text("Year.")
                .font(Font.custom("Poppins-Bold", size: 35))
                .foregroundColor(.white)
        }
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView()
    }
}
