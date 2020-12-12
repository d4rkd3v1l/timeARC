//
//  Icon.swift
//  timetracker
//
//  Created by d4Rk on 12.12.20.
//

import SwiftUI

struct Icon: View {
    var body: some View {
        ArcViewFull(duration: 10,
                    maxDuration: 20,
                    color: .green,
                    allowedUnits: [.minute, .second],
                    displayMode: .countUp)
    }
}

struct Icon_Previews: PreviewProvider {
    static var previews: some View {
        Icon()
    }
}
