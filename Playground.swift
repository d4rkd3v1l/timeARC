//
//  Playground.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 22.07.20.
//

import SwiftUI

struct TestDatePicker: View {

    @State var date = Date()

    var body: some View {
            DatePicker(selection: Binding(get: {
                self.date
            }, set: { newVal in
                self.date = newVal
                self.doSomething(with: newVal)
            })) {
                Text("")
            }
    }

    func doSomething(with: Date) {
        print("-----> in doSomething")
    }
}

struct TestDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        TestDatePicker()
    }
}
