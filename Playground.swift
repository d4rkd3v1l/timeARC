//
//  Playground.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 22.07.20.
//

import SwiftUI

struct PlaygroundView: View {
    @State private var expandedId: Int?

    func isExpanded(id: Int) -> Binding<Bool> {
        return Binding(
            get: { id == self.expandedId },
            set: { self.expandedId = $0 == true ? id : nil }
        )
    }

    func toggleExpanded(for id: Int) {
        self.expandedId = self.expandedId == id ? nil : id
    }

    var body: some View {
        Form {
            ForEach(0 ..< 3) { id in
                DisclosureTest(id: id, isExpanded: self.isExpanded(id: id))
                    .onTapGesture {
                        withAnimation { self.toggleExpanded(for: id) }
                    }
            }
        }
    }
}

struct DisclosureTest: View {
    let id: Int
    @Binding var isExpanded: Bool

    var body: some View {
        DisclosureGroup("\(self.id)", isExpanded: self.$isExpanded) {
            Text("open")
        }
    }
}

struct PlaygroundView_Previews: PreviewProvider {
    static var previews: some View {
        PlaygroundView()
    }
}
