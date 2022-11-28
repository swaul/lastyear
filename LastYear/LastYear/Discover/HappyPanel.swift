//
//  HappyPanel.swift
//  LastYear
//
//  Created by Paul Kühnel on 28.11.22.
//

import Foundation
import SwiftUI
import Shared
import UIKit

struct HappyPanel: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @Binding var selectedEmoji: Emoji?
    @Binding var isSearching: Bool
    
    @State var isDraggingDown: Bool = false
    
    @ObservedObject var sharedState = SharedState()
    
    var body: some View {
        ZStack {
            
            MainContent()
                .onChange(of: sharedState.selectedEmoji) { value in
                    if let value = value {
                        selectedEmoji = value
                        EmojiStore.saveRecentEmoji(value)
                        resetViews()
                    }
                }
                .environmentObject(sharedState)
                .edgesIgnoringSafeArea(.bottom)
                .onChange(of: sharedState.isSearching) { newValue in
                    isSearching = newValue
                }
            
            if !isDraggingDown, !sharedState.isSearching, sharedState.keyword.isEmpty {
                self.sectionPicker
            }
        }
    }
    
    private var displayedCategories: [String] {
        if EmojiStore.fetchRecentList().isEmpty {
            return SectionType.defaultCategories.map { $0.rawValue }
        }
        return SectionType.allCases.map { $0.rawValue }
    }
    
    private var sectionPicker: some View {
        VStack {
            Spacer()
            
            SectionIndexPicker(sections: displayedCategories)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .environmentObject(sharedState)
        }
    }
    
    private func resetViews() {
        sharedState.resetState()
        presentationMode.wrappedValue.dismiss()
    }
}

struct MainContent: View {
    @EnvironmentObject var sharedState: SharedState
    
    var emojiStore = EmojiStore.shared
    
    var body: some View {
        VStack {
            
            VStack(spacing: 0) {
                SearchBar()
                    .padding(16)
                    .environmentObject(sharedState)
                
                self.separator
                
                ZStack {
                    self.emojiSections
                    
                    if sharedState.isSearching || !sharedState.keyword.isEmpty {
                        self.emojiResults
                    }
                }
            }
            .background(Color.background)
            .cornerRadius(8)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private var indicator: some View {
        Color.gray
            .frame(width: 60, height: 6)
            .clipShape(Capsule())
    }
    
    private var separator: some View {
        Color.gray
            .opacity(0.2)
            .frame(height: 1)
    }
    
    private var emojiSections: some View {
        ScrollViewReader { proxy in
            List {
                Group {
                    if !EmojiStore.fetchRecentList().isEmpty {
                        EmojiSection(
                            title: SectionType.recent.rawValue,
                            items: EmojiStore.fetchRecentList(),
                            contentKeyPath: \.self) { emoji in
                            guard let item = emojiStore.allEmojis.first(where: { $0.string == emoji }) else { return }
                            self.sharedState.selectedEmoji = item
                        }
                        .id(SectionType.recent.rawValue)
                    }
                    
                    ForEach(SectionType.defaultCategories.map { $0.rawValue }, id: \.self) { category in
                        EmojiSection(
                            title: category,
                            items: emojiStore.emojisByCategory[category]!,
                            contentKeyPath: \.string) {
                            self.sharedState.selectedEmoji = $0
                        }
                    }
                }
                .onChange(of: sharedState.currentCategory) { target in
                    proxy.scrollTo(target, anchor: .top)
                }
                
                Color.background
                    .frame(height: 24)
            }
        }
    }
    
    private var emojiResults: some View {
        Group {
            if sharedState.keyword.isEmpty {
                EmptyView()
            } else if emojiStore.filteredEmojis(with: sharedState.keyword).isEmpty {
                
                VStack {
                    Text("No emoji results found for \"\(sharedState.keyword)\"")
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.top, 32)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color.background)
                
            } else {
                List {
                    EmojiSection(
                        title: "Search Results",
                        items: emojiStore.filteredEmojis(with: sharedState.keyword),
                        contentKeyPath: \.string) {
                        self.sharedState.selectedEmoji = $0
                    }
                    .background(Color.background)
                }
            }
        }
    }
}

struct SearchBar: View {
    @EnvironmentObject var sharedState: SharedState
    
    var body: some View {
        HStack {
            TextField("Search emoji", text: $sharedState.keyword, onEditingChanged: { inFocus in
                sharedState.isSearching = inFocus
            })
            .font(.body)
            .padding(8)
            .padding(.horizontal, 28)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 12)
             
                    if !sharedState.keyword.isEmpty {
                        Button(action: {
                            self.sharedState.keyword = ""
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 12)
                        }
                    }
                }
            )
            
            if sharedState.isSearching {
                Button(action: {
                    self.sharedState.isSearching = false
                    self.sharedState.keyword = ""
//                    UIApplication.shared.endEditing()
                }) {
                    Text("Cancel")
                }
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
        
    }
}
