//
//  WatchSizeHelper.swift
//  watch Extension
//
//  Created by d4Rk on 30.08.20.
//

import WatchKit

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
