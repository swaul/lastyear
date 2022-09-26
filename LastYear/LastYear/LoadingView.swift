//
//  LoadingView.swift
//  LastYear
//
//  Created by Paul Kühnel on 24.09.22.
//

import SwiftUI
import Combine

let loadingDone = PassthroughSubject<Bool, Never>()

struct LoadingView: View {
    
    @State var animating: Bool = false
    @State var loaded: Bool = false
    
    var animation = Animation
        .easeInOut(duration: 2)
        .repeatForever()
    
    var offset: CGFloat {
        if loaded {
            return 0
        } else {
            return animating ? 50 : -50
        }
    }
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                Color("backgroundColor")
                GeometryReader { imageReader in
                    Image("stars")
                        .resizable()
                        .frame(maxWidth: .infinity, alignment: .top)
                        .aspectRatio(1, contentMode: .fit)
                        .offset(x: 0, y: -imageReader.size.height)
                        .offset(x: 0, y: animating ? reader.size.height + imageReader.size.height : 0)
                        .animation(Animation.linear(duration: 2).repeatForever(autoreverses: false), value: animating)
                }
                
                GeometryReader { imageReader in
                    Image("stars")
                        .resizable()
                        .frame(maxWidth: .infinity, alignment: .top)
                        .aspectRatio(1, contentMode: .fit)
                        .offset(x: 0, y: -imageReader.size.height)
                        .offset(x: 0, y: animating ? reader.size.height + imageReader.size.height : 0)
                        .animation(Animation.linear(duration: 2).repeatForever(autoreverses: false).delay(1), value: animating)
                        .padding(.horizontal)
                }
                Image("rocket")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: reader.size.width / 2, alignment: .center)
                    .offset(x: -offset, y: offset)
                    .animation(Animation.spring(response: 0.8, dampingFraction: 0.4, blendDuration: 0.2).repeatForever(autoreverses: true), value: animating)
                    .offset(y: loaded ? -1000 : 0)
                    .animation(.easeIn(duration: 1), value: loaded)
                    .onAppear {
                        animating.toggle()
                    }
                    .onReceive(loadingDone) { value in
                        withAnimation {
                            loaded = value
                        }
                    }
                VStack {
                    Spacer()
                    Text("Loading")
                        .font(Font.custom("Poppins-Bold", size: 35))
                        .foregroundColor(Color("primary"))
                        .offset(x: 0, y: animating ? -10 : 0)
                        .animation(Animation.easeInOut.repeatForever(autoreverses: true), value: animating)
                        .padding(.bottom, 64)
                }
            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
