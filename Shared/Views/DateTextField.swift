//
//  DateTextField.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 15.08.20.
//

import UIKit
import SwiftUI

// https://diamantidis.github.io/2020/06/21/keyboard-options-for-swiftui-fields

class DateTextField: UITextField {
    // MARK: - Public properties
    @Binding var date: Date?

    // MARK: - Initializers
    init(date: Binding<Date?>) {
        self._date = date
        super.init(frame: .zero)

        if let date = date.wrappedValue {
            self.datePickerView.date = date
        }

        self.datePickerView.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        self.inputView = datePickerView
        self.tintColor = .clear
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private properties
    private lazy var datePickerView: UIDatePicker = {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        return datePickerView
    }()

    // MARK: - Private methods
    @objc func dateChanged(_ sender: UIDatePicker) {
        self.date = sender.date
    }
}

struct DateField: UIViewRepresentable {
    // MARK: - Public properties
    @Binding var date: Date?

    // MARK: - Initializers
    init<S>(_ title: S, date: Binding<Date?>, formatter: DateFormatter = .yearMonthDay) where S: StringProtocol {
        self.placeholder = String(title)
        self._date = date

        self.textField = DateTextField(date: date)
        self.formatter = formatter
    }

    // MARK: - Public methods
    func makeUIView(context: UIViewRepresentableContext<DateField>) -> UITextField {
        textField.placeholder = placeholder
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<DateField>) {
        if let date = date {
            uiView.text = formatter.string(from: date)
        }
    }

    // MARK: - Private properties
    private var placeholder: String
    private let formatter: DateFormatter
    private let textField: DateTextField
}

extension DateFormatter {
    static var yearMonthDay: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}
