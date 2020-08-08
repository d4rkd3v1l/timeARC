//
//  Playground.swift
//  timetracker (iOS)
//
//  Created by d4Rk on 22.07.20.
//

import SwiftUI

// MARK: - Preview

struct PlaygroundView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ZStack {
                ArcView(color: Color.accentColor, progress: 0.78)
                Text("70%")
                    .font(.system(size: 60)).bold()

                Text("06:23:12")
                    .font(.system(size: 28)).bold()
                    .offset(x: 0, y: 100)
            }
            .accentColor(.green)
            .frame(width: 250, height: 250)

            HStack {
                ForEach((12...18), id: \.self) { index in
                    return ZStack {
                        if index < 16 {
                            ArcView(color: Color.accentColor, progress: Double.random(in: 0.8...1.5))
                            Text("\(index)")
                                .font(.system(size: 20)).bold()

                            Text("\(Int.random(in: -10...30))")
                                .font(.system(size: 10)).bold()
                                .offset(x: 0, y: 17)
                        } else {
                            ArcView(color: .gray, progress: 0)
                            Text("\(index)")
                                .font(.system(size: 20)).bold()
                        }
                    }
                    .accentColor(.green)
                    .frame(width: 40, height: 40)
                }
            }
        }
    }
}

