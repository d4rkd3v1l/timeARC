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

protocol SingleValueSelectable: Identifiable, Equatable {
    var localizedTitle: String { get }
}

// Heavily inspired by https://www.pawelmadej.com/post/multi-select-picker-for-swiftui/
struct MultipleValuesPickerView<Item: MultipleValuesSelectable>: View {
    private var selectionChanged: (([Item]) -> Void)?

    @Environment(\.presentationMode) var presentationMode
    @State private var selections: [Item]

    init(initial: [Item]) {
        _selections = State(initialValue: initial)
    }
    
    var body: some View {
        ForEach(Item.availableItems) { item in
            SelectableItemView(title: item.title, isSelected: self.selections.contains(item)) {
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
    }
    
    func onSelectionChange(perform action: (([Item]) -> Void)? = nil) -> some View {
        var copy = self
        copy.selectionChanged = action
        return copy
    }
}

struct SingleValuePickerView<Item: SingleValueSelectable>: View {
    private let availableItems: [Item]
    private var selectionChanged: ((Item) -> Void)?

    @Environment(\.presentationMode) var presentationMode
    @State private var selection: Item

    init(availableItems: [Item], selection: Item) {
        self.availableItems = availableItems
        _selection = State(initialValue: selection)
    }

    var body: some View {
        ForEach(self.availableItems) { item in
            SelectableItemView(title: item.localizedTitle, isSelected: self.selection == item) {
                self.selection = item
                self.selectionChanged?(self.selection)
            }
        }
    }

    func onSelectionChange(perform action: ((Item) -> Void)? = nil) -> some View {
        var copy = self
        copy.selectionChanged = action
        return copy
    }
}

struct SelectableItemView: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
            HStack {
                Text(self.title)
                    .foregroundColor(.primary)
                Spacer()

                if self.isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                self.action()
            }
    }
}
