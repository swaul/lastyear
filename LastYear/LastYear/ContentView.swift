//
//  ContentView.swift
//  LastYear
//
//  Created by Paul Kühnel on 23.09.22.
//

import SwiftUI

struct ContentView: View {
    
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var photos = [
        PhotoData(id: UUID().uuidString, image: Image("Image1")),
        PhotoData(id: UUID().uuidString, image: Image("Image2")),
        PhotoData(id: UUID().uuidString, image: Image("Image3")),
        PhotoData(id: UUID().uuidString, image: Image("Image4")),
        PhotoData(id: UUID().uuidString, image: Image("Image5")),
        PhotoData(id: UUID().uuidString, image: Image("Image6")),
        PhotoData(id: UUID().uuidString, image: Image("Image7"))
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
