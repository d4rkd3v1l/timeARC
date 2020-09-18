//
//  MultipleValuesPickerView.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 28.08.20.
//

import SwiftUI

protocol MultipleValuesSelectable: Identifiable, Equatable {
    static var availableItems: [Self] { get }
    var title: String { get }
}

// Heavily inspired by https://www.pawelmadej.com/post/multi-select-picker-for-swiftui/
struct MultipleValuesPickerView<Item: MultipleValuesSelectable>: View {
    @Environment(\.presentationMode) var presentationMode
    let title: LocalizedStringKey
    let sectionHeader: LocalizedStringKey
    let initial: [Item]
    @State private var selections: [Item] = []
    var selectionChanged: (([Item]) -> Void)?

    init(title: LocalizedStringKey, sectionHeader: LocalizedStringKey, initial: [Item]) {
        self.title = title
        self.sectionHeader = sectionHeader
        self.initial = initial
    }
    
    var body: some View {
        ForEach(Item.availableItems) { item in
            MultipleValuesPicker(title: item.title, isSelected: self.selections.contains(item)) {
                if self.selections.contains(item) {
                    self.selections.removeAll(where: { $0 == item })
                    self.selectionChanged?(self.selections)
                }
                else {
                    self.selections.append(item)
                    self.selectionChanged?(self.selections)
                }
            }
        }
        .onAppear { self.selections = self.initial }
    }
    
    func onSelectionChange(perform action: (([Item]) -> Void)? = nil) -> some View {
        var copy = self
        copy.selectionChanged = action
        return copy
    }
}

struct MultipleValuesPicker: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(self.title)
                    .foregroundColor(.primary)

                if self.isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}
