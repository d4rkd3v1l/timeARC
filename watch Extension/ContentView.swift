//
//  ContentView.swift
//  watch Extension
//
//  Created by d4Rk on 23.08.20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Spacer()
            ArcViewFull(duration: 42,
                        maxDuration: 125)
                .frame(width: self.arcSize, height: self.arcSize)
            Spacer()
            Button(action: {
//                store.dispatch(action: ToggleTimer())
            }) {
                Text(LocalizedStringKey("Start"))
                    .frame(maxWidth: .infinity)
                    .frame(height: WatchHelper.buttonHeight)
                    .font(Font.body.bold())
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .cornerRadius(WatchHelper.buttonHeight / 2)
            }
            .buttonStyle(PlainButtonStyle())
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }

    private var arcSize: CGFloat {
        return WKInterfaceDevice.current().screenBounds.size.height * 0.53
    }
}

enum WatchSize {
    case unknown
    case _38
    case _42
    case _40
    case _44
}

struct WatchHelper {
    static var watchSize: WatchSize {
        switch WKInterfaceDevice.current().screenBounds.size.height {
        case 170.0: return ._38
        case 195.0: return ._42
        case 197.0: return ._40
        case 224.0: return ._44
        default:    return .unknown
        }
    }

    static var buttonHeight: CGFloat {
        switch watchSize {
        case .unknown:  return 40.0
        case ._38:      return 38.0
        case ._42:      return 40.0
        case ._40:      return 40.0
        case ._44:      return 44.0
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .accentColor(.green)
    }
}
