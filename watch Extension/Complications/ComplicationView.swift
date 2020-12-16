//
//  ComplicationView.swift
//  watch Extension
//
//  Created by d4Rk on 30.08.20.
//

import SwiftUI
import WatchKit
import ClockKit

struct ComplicationView: View {
    let duration: Int
    let maxDuration: Int
    let displayMode: TimerDisplayMode

    var body: some View {
        ArcViewFull(duration: self.duration,
                    maxDuration: self.maxDuration,
                    color: .accentColor,
                    allowedUnits: [.hour, .minute],
                    displayMode: self.displayMode)
    }
}

enum ComplicationIdentifier: String {
    case standard
    case alternative
    case alternative2
}

struct ComplicationProvider {
    let duration: Int
    let maxDuration: Int
    let color: UIColor
    let displayMode: TimerDisplayMode

    func complication(for family: CLKComplicationFamily, identifier: ComplicationIdentifier = .standard) -> CLKComplicationTemplate? {
        let complicationView = ComplicationView(duration: self.duration,
                                                maxDuration: self.maxDuration,
                                                displayMode: self.displayMode)
            .accentColor(Color(color))

        let durationFormatted = self.displayMode.text(for: self.duration,
                                                      maxDuration: self.maxDuration,
                                                      allowedUnits: [.hour, .minute]).firstLine
        let percent = Float(self.duration) / Float(self.maxDuration)
        let percentFormatted = String(Int(percent * 100.0))
        let onePieceImage = UIImage() // TODO: provide image
        let fullColorImage = UIImage() // TODO: provide image
        let header = "timeARC"

        switch family {
        case .modularSmall:
            return CLKComplicationTemplateModularSmallRingText(textProvider: CLKTextProvider(format: percentFormatted),
                                                               fillFraction: percent,
                                                               ringStyle: .open)

        case .modularLarge:
            switch identifier {
            case .standard:
                return CLKComplicationTemplateModularLargeTallBody(headerTextProvider: CLKTextProvider(format: header),
                                                                   bodyTextProvider: CLKTextProvider(format: durationFormatted))

            case .alternative:
                return CLKComplicationTemplateModularLargeTable(headerImageProvider: CLKImageProvider(onePieceImage: onePieceImage),
                                                                headerTextProvider: CLKTextProvider(format: header),
                                                                row1Column1TextProvider: CLKTextProvider(format: "Hours"),
                                                                row1Column2TextProvider: CLKTextProvider(format: durationFormatted),
                                                                row2Column1TextProvider: CLKTextProvider(format: "Percent"),
                                                                row2Column2TextProvider: CLKTextProvider(format: percentFormatted))

            default:
                return nil
            }

        case .utilitarianSmall:
            return CLKComplicationTemplateUtilitarianSmallRingText(textProvider: CLKTextProvider(format: percentFormatted),
                                                                   fillFraction: percent,
                                                                   ringStyle: .open)
        case .utilitarianSmallFlat:
            return CLKComplicationTemplateUtilitarianSmallFlat(textProvider: CLKTextProvider(format: durationFormatted),
                                                               imageProvider: CLKImageProvider(onePieceImage: onePieceImage))

        case .utilitarianLarge:
            return CLKComplicationTemplateUtilitarianLargeFlat(textProvider: CLKTextProvider(format: "\(durationFormatted) • \(percentFormatted) pct"),
                                                               imageProvider: CLKImageProvider(onePieceImage: onePieceImage))

        case .circularSmall:
            switch identifier {
            case .standard:
                return CLKComplicationTemplateCircularSmallRingText(textProvider: CLKTextProvider(format: percentFormatted),
                                                                    fillFraction: percent,
                                                                    ringStyle: .open)

            case .alternative:
                return CLKComplicationTemplateCircularSmallSimpleText(textProvider: CLKTextProvider(format: durationFormatted))

            default:
                return nil
            }

        case .extraLarge:
            switch identifier {
            case .standard:
                return CLKComplicationTemplateExtraLargeRingText(textProvider: CLKTextProvider(format: percentFormatted),
                                                                 fillFraction: percent,
                                                                 ringStyle: .open)

            case .alternative:
                return CLKComplicationTemplateExtraLargeStackText(line1TextProvider: CLKTextProvider(format: " \(durationFormatted) "),
                                                                  line2TextProvider: CLKTextProvider(format: percentFormatted))

            case .alternative2:
                return CLKComplicationTemplateExtraLargeSimpleText(textProvider: CLKTextProvider(format: " \(durationFormatted) "))
            }

        case .graphicCorner:
            switch identifier {
            case .standard:
                return CLKComplicationTemplateGraphicCornerGaugeText(gaugeProvider: CLKSimpleGaugeProvider(style: .fill,
                                                                                                           gaugeColor: self.color,
                                                                                                           fillFraction: percent),
                                                                     outerTextProvider: CLKTextProvider(format: durationFormatted))

            case .alternative:
                return CLKComplicationTemplateGraphicCornerGaugeImage(gaugeProvider: CLKSimpleGaugeProvider(style: .fill,
                                                                                                            gaugeColor: self.color,
                                                                                                            fillFraction: percent),
                                                                      leadingTextProvider: CLKTextProvider(format: durationFormatted),
                                                                      trailingTextProvider: nil,
                                                                      imageProvider: CLKFullColorImageProvider(fullColorImage: fullColorImage))
            case .alternative2:
                return CLKComplicationTemplateGraphicCornerTextImage(textProvider: CLKTextProvider(format: "\(durationFormatted) • \(percentFormatted) pct"),
                                                                     imageProvider: CLKFullColorImageProvider(fullColorImage: fullColorImage))
            }

        case .graphicBezel:
            return CLKComplicationTemplateGraphicBezelCircularText(circularTemplate: CLKComplicationTemplateGraphicCircularView(complicationView),
                                                                   textProvider: CLKTextProvider(format: "\(durationFormatted) • \(percentFormatted) pct"))

        case .graphicCircular:
            return CLKComplicationTemplateGraphicCircularView(complicationView)

        case .graphicRectangular:
            return CLKComplicationTemplateGraphicRectangularTextGauge(headerImageProvider: CLKFullColorImageProvider(fullColorImage: fullColorImage),
                                                               headerTextProvider: CLKTextProvider(format: header),
                                                               body1TextProvider: CLKTextProvider(format: "\(durationFormatted) hrs • \(percentFormatted) pct"),
                                                               gaugeProvider: CLKSimpleGaugeProvider(style: .fill,
                                                                                                     gaugeColor: color,
                                                                                                     fillFraction: percent))

        case .graphicExtraLarge:
            return CLKComplicationTemplateGraphicExtraLargeCircularView(complicationView)

        @unknown default:
            return nil
        }
    }
}

struct ModularSmallPreview: PreviewProvider {
    static var previews: some View {
        ComplicationProvider(duration: 12096,
                             maxDuration: 28800,
                             color: .green,
                             displayMode: .endOfWorkingDay)
            .complication(for: .modularSmall)!
            .previewContext()
    }
}

struct ModularLargePreview: PreviewProvider {
    static var previews: some View {
        Group {
            ComplicationProvider(duration: 12096,
                                 maxDuration: 28800,
                                 color: .green,
                                 displayMode: .endOfWorkingDay)
                .complication(for: .modularLarge)!
                .previewContext()

            ComplicationProvider(duration: 12096,
                                 maxDuration: 28800,
                                 color: .green,
                                 displayMode: .endOfWorkingDay)
                .complication(for: .modularLarge, identifier: .alternative)!
                .previewContext()
        }
    }
}

struct UtilitarianSmallPreview: PreviewProvider {
    static var previews: some View {
        ComplicationProvider(duration: 12096,
                             maxDuration: 28800,
                             color: .green,
                             displayMode: .endOfWorkingDay)
            .complication(for: .utilitarianSmall)!
            .previewContext()
    }
}

struct UtilitarianSmallFlatPreview: PreviewProvider {
    static var previews: some View {
        ComplicationProvider(duration: 12096,
                             maxDuration: 28800,
                             color: .green,
                             displayMode: .endOfWorkingDay)
            .complication(for: .utilitarianSmallFlat)!
            .previewContext()
    }
}

struct UtilitarianLargePreview: PreviewProvider {
    static var previews: some View {
        ComplicationProvider(duration: 12096,
                             maxDuration: 28800,
                             color: .green,
                             displayMode: .endOfWorkingDay)
            .complication(for: .utilitarianLarge)!
            .previewContext()
    }
}

struct CircularSmallPreview: PreviewProvider {
    static var previews: some View {
        Group {
            ComplicationProvider(duration: 12096,
                                 maxDuration: 28800,
                                 color: .green,
                                 displayMode: .endOfWorkingDay)
                .complication(for: .circularSmall)!
                .previewContext()

            ComplicationProvider(duration: 12096,
                                 maxDuration: 28800,
                                 color: .green,
                                 displayMode: .endOfWorkingDay)
                .complication(for: .circularSmall, identifier: .alternative)!
                .previewContext()
        }
    }
}

struct ExtraLargePreview: PreviewProvider {
    static var previews: some View {
        Group {
            ComplicationProvider(duration: 12096,
                                 maxDuration: 28800,
                                 color: .green,
                                 displayMode: .endOfWorkingDay)
                .complication(for: .extraLarge)!
                .previewContext()

            ComplicationProvider(duration: 12096,
                                 maxDuration: 28800,
                                 color: .green,
                                 displayMode: .endOfWorkingDay)
                .complication(for: .extraLarge, identifier: .alternative)!
                .previewContext()

            ComplicationProvider(duration: 12096,
                                 maxDuration: 28800,
                                 color: .green,
                                 displayMode: .endOfWorkingDay)
                .complication(for: .extraLarge, identifier: .alternative2)!
                .previewContext()
        }
    }
}

struct GraphicCornerPreview: PreviewProvider {
    static var previews: some View {
        Group {
            ComplicationProvider(duration: 12096,
                                 maxDuration: 28800,
                                 color: .green,
                                 displayMode: .endOfWorkingDay)
                .complication(for: .graphicCorner)!
                .previewContext()

            ComplicationProvider(duration: 12096,
                                 maxDuration: 28800,
                                 color: .green,
                                 displayMode: .endOfWorkingDay)
                .complication(for: .graphicCorner, identifier: .alternative)!
                .previewContext()

            ComplicationProvider(duration: 12096,
                                 maxDuration: 28800,
                                 color: .green,
                                 displayMode: .endOfWorkingDay)
                .complication(for: .graphicCorner, identifier: .alternative2)!
                .previewContext()
        }
    }
}

struct GraphicBezelPreview: PreviewProvider {
    static var previews: some View {
        ComplicationProvider(duration: 12096,
                             maxDuration: 28800,
                             color: .green,
                             displayMode: .endOfWorkingDay)
            .complication(for: .graphicBezel)!
            .previewContext()
    }
}

struct GraphicCircularPreview: PreviewProvider {
    static var previews: some View {
        ComplicationProvider(duration: 12096,
                             maxDuration: 28800,
                             color: .green,
                             displayMode: .endOfWorkingDay)
            .complication(for: .graphicCircular)!
            .previewContext()
    }
}

struct GraphicRectangularPreview: PreviewProvider {
    static var previews: some View {
        ComplicationProvider(duration: 12096,
                             maxDuration: 28800,
                             color: .green,
                             displayMode: .endOfWorkingDay)
            .complication(for: .graphicRectangular)!
            .previewContext()
    }
}

struct GraphicExtraLargePreview: PreviewProvider {
    static var previews: some View {
        ComplicationProvider(duration: 12096,
                             maxDuration: 28800,
                             color: .green,
                             displayMode: .endOfWorkingDay)
            .complication(for: .graphicExtraLarge)!
            .previewContext()
    }
}
