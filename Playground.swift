//
//  Playground.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 22.07.20.
//

import SwiftUI

struct PlaygroundView: View {
    var body: some View {
        Text("Hello, world!")
            .popover(isPresented: .constant(true), content: {
                Text("bla")
            })
    }
}

// MARK: - Preview

struct PlaygroundView_Previews: PreviewProvider {
    @State static var date = Date()
    static var previews: some View {
        PlaygroundView()
    }
}

