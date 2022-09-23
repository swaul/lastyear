//
//  ContentView.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import SwiftUI

struct ContentView: View {
    
    let layout = [
        GridItem(.fixed(80)),
        GridItem(.fixed(80)),
        GridItem(.fixed(80))
    ]
    
    var photos = [
        PhotoData(id: UUID().uuidString, image: Image("image1")),
        PhotoData(id: UUID().uuidString, image: Image("image2"))
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: layout) {
                ForEach(photos) { photo in
                    PhotoCard(image: photo)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
