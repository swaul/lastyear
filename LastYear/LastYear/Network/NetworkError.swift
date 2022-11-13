//
//  NetworkError.swift
//  LastYear
//
//  Created by Paul Kühnel on 13.11.22.
//

import SwiftUI

struct NetworkError: View {
    var body: some View {
        Text("Connection Lost")
            .font(Font.custom("Poppins-Regular", size: 24))
            .foregroundColor(.white)
            .onTapGesture {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            }
    }
}

struct NetworkError_Previews: PreviewProvider {
    static var previews: some View {
        NetworkError()
    }
}
