//
//  SettingsDetailView.swift
//  LastYear
//
//  Created by Paul Kühnel on 13.12.22.
//

import SwiftUI

struct SettingsDetailView: View {
    
    var item: MenuItem
    var user: LYUser
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            List(item.options, id: \.id) { option in
                SettingsRow(option: option, user: user)
                    .onTapGesture {
                        
                    }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .navigationTitle(item.name)
        }
    }
    
}
