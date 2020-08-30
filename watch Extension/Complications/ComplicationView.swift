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
    var body: some View {
        ArcViewFull(duration: 20000,
                    maxDuration: 28800,
                    color: .accentColor,
                    allowedUnits: [.hour, .minute])
            .accentColor(.green)
    }
}

struct ComplicationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Modular Small (0)
            Group {
                CLKComplicationTemplateGraphicCircularView(ComplicationView())
                    .previewContext()
            }

            // Modular Large (1)
            Group {
                CLKComplicationTemplateModularLargeTable(headerImageProvider: CLKImageProvider(onePieceImage: UIImage()),
                                                         headerTextProvider: CLKTextProvider(format: "Time Tracker"),
                                                         row1Column1TextProvider: CLKTextProvider(format: "Hours"),
                                                         row1Column2TextProvider: CLKTextProvider(format: "06:42"),
                                                         row2Column1TextProvider: CLKTextProvider(format: "Percent"),
                                                         row2Column2TextProvider: CLKTextProvider(format: "78"))
                    .previewContext()

                CLKComplicationTemplateModularLargeTallBody(headerTextProvider: CLKTextProvider(format: "Time Tracker"),
                                                            bodyTextProvider: CLKTextProvider(format: "06:42"))
                    .previewContext()
            }

            // Utilitarian Small (2)
            Group {
                CLKComplicationTemplateUtilitarianSmallRingText(textProvider: CLKTextProvider(format: "78"),
                                                                fillFraction: 0.78,
                                                                ringStyle: .open)
                    .previewContext()
            }

            // Utilitarian Large (3)
            Group {
                CLKComplicationTemplateUtilitarianLargeFlat(textProvider: CLKTextProvider(format: "06:42 • 78 pct"),
                                                            imageProvider: CLKImageProvider(onePieceImage: UIImage()))
                    .previewContext()
            }

            // Circular Small (4)
            Group {
                CLKComplicationTemplateCircularSmallRingText(textProvider: CLKTextProvider(format: "78"),
                                                             fillFraction: 0.3,
                                                             ringStyle: .open)
                    .previewContext()


                CLKComplicationTemplateCircularSmallStackText(line1TextProvider: CLKTextProvider(format: "06:42"),
                                                              line2TextProvider: CLKTextProvider(format: "78"))
                    .previewContext()

                CLKComplicationTemplateCircularSmallSimpleText(textProvider: CLKTextProvider(format: "06:42"))
                    .previewContext()
            }

            // Utilitarian Small Flat (6)
            Group {
                CLKComplicationTemplateUtilitarianSmallFlat(textProvider: CLKTextProvider(format: "06:42"),
                                                            imageProvider: CLKImageProvider(onePieceImage: UIImage()))
                    .previewContext()
            }
        }
    }
}

struct ComplicationView2_Previews: PreviewProvider {
    static var previews: some View {
        Group {

            // Extra Large (7)
            Group {
                CLKComplicationTemplateExtraLargeRingText(textProvider: CLKTextProvider(format: "78"),
                                                          fillFraction: 0.78,
                                                          ringStyle: .open)
                    .previewContext()

                CLKComplicationTemplateExtraLargeStackText(line1TextProvider: CLKTextProvider(format: "6:42"),
                                                           line2TextProvider: CLKTextProvider(format: "78"))
                    .previewContext()

                CLKComplicationTemplateExtraLargeSimpleText(textProvider: CLKTextProvider(format: " 06:42 "))
                    .previewContext()

                    CLKComplicationTemplateExtraLargeColumnsText(row1Column1TextProvider: CLKTextProvider(format: "HRS"),
                                                                 row1Column2TextProvider: CLKTextProvider(format: "6:42"),
                                                                 row2Column1TextProvider: CLKTextProvider(format: "PCT"),
                                                                 row2Column2TextProvider: CLKTextProvider(format: "78"))
                        .previewContext()
            }

            // Graphic Corner (8)
            Group {
                CLKComplicationTemplateGraphicCornerGaugeText(gaugeProvider: CLKSimpleGaugeProvider(style: .fill,
                                                                                                    gaugeColor: .green,
                                                                                                    fillFraction: 0.3),
                                                              outerTextProvider: CLKTextProvider(format: "06:42"))
                    .previewContext()

                CLKComplicationTemplateGraphicCornerGaugeImage(gaugeProvider: CLKSimpleGaugeProvider(style: .fill,
                                                                                                     gaugeColor: .green,
                                                                                                     fillFraction: 0.3),
                                                               leadingTextProvider: CLKTextProvider(format: "06:42"),
                                                               trailingTextProvider: nil,
                                                               imageProvider: CLKFullColorImageProvider(fullColorImage: UIImage()))
                    .previewContext()

                CLKComplicationTemplateGraphicCornerTextImage(textProvider: CLKTextProvider(format: "06:42 • 78 pct"),
                                                              imageProvider: CLKFullColorImageProvider(fullColorImage: UIImage()))
                    .previewContext()

                CLKComplicationTemplateGraphicCornerStackText(innerTextProvider: CLKTextProvider(format: "78 pct"),
                                                              outerTextProvider: CLKTextProvider(format: "06:42"))
                    .previewContext()
            }

            // Graphic Bezel (9)
            Group {
                CLKComplicationTemplateGraphicBezelCircularText(circularTemplate: CLKComplicationTemplateGraphicCircularView(ComplicationView()),
                                                                textProvider:  CLKTextProvider(format: "06:42 hrs • 78 pct"))
                    .previewContext()
            }

//            // Graphic Circular (10)
//            Group {
//                CLKComplicationTemplateGraphicCircularView(ComplicationView())
//                    .previewContext()
//            }

            // Graphic Rectangular (11)
            Group {
                CLKComplicationTemplateGraphicRectangularTextGauge(headerImageProvider: CLKFullColorImageProvider(fullColorImage: UIImage()),
                                                                   headerTextProvider: CLKTextProvider(format: "Time Tracker"),
                                                                   body1TextProvider: CLKTextProvider(format: "06:42 hrs • 78 pct"),
                                                                   gaugeProvider: CLKSimpleGaugeProvider(style: .fill,
                                                                                                         gaugeColor: .green,
                                                                                                         fillFraction: 0.3))
                    .previewContext()
            }

            // Graphic Extra Large (12)
            Group {
                CLKComplicationTemplateGraphicExtraLargeCircularView(ComplicationView())
                    .previewContext()
            }
        }
    }
}

