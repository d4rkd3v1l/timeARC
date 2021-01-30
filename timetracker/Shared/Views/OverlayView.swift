//
//  OverlayView.swift
//  timeARC
//
//  Created by d4Rk on 19.12.20.
//

import SwiftUI

struct TestView: View {
    @Namespace var namespace
    @State private var showOverlay = false

    @State private var date = Date()

    var body: some View {
        ZStack {
            Form {
                DatePicker("", selection: $date)
                HStack {
                    Text("Test")
                    Spacer()
                    Text("Text")
                }
                .frame(width: 300, height: 30)
                .matchedGeometryEffect(id: "id1", in: self.namespace)
                .onTapGesture {
                    withAnimation {
                        self.showOverlay.toggle()
                    }
                }
            }
//            .background(showOverlay ? Color.black : .clear)
//            .opacity(showOverlay ? 0.5 : 1.0)
//            .blur(radius: showOverlay ? 3.0 : 0.0)
//            .ignoresSafeArea()

            if self.showOverlay {
                VStack {
                    Spacer()

                    VStack {
                        Text("Overlay")
                    }
                    .frame(width: 300, height: 100)
                    .background(Color.gray)
                    .cornerRadius(25)
                    .matchedGeometryEffect(id: "id1", in: self.namespace)
                    .onTapGesture {
                        withAnimation {
                            self.showOverlay.toggle()
                        }
                    }

                    Spacer()
                }
            }
        }
    }
}

struct OverlayView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
