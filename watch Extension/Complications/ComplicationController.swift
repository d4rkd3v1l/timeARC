//
//  ComplicationController.swift
//  watch Extension
//
//  Created by d4Rk on 23.08.20.
//

import ClockKit


// CLKComplicationServer
//   reloadTimeline
//   extendTimeline


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Complication Configuration

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: ComplicationIdentifier.standard.rawValue,
                                      displayName: "Default",
                                      supportedFamilies: CLKComplicationFamily.allCases),

            CLKComplicationDescriptor(identifier: ComplicationIdentifier.alternative.rawValue,
                                      displayName: "Alternative",
                                      supportedFamilies: [.modularLarge, .circularSmall, .extraLarge, .graphicCorner]),

            CLKComplicationDescriptor(identifier: ComplicationIdentifier.alternative2.rawValue,
                                      displayName: "Alternative",
                                      supportedFamilies: [.extraLarge, .graphicCorner])
        ]

        handler(descriptors)
    }
    
    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        // Do any necessary work to support these newly shared complication descriptors
    }

    // MARK: - Timeline Configuration
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // Call the handler with the last entry date you can currently provide or nil if you can't support future timelines
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }

    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        let timeEntries = store.state.timeEntries
        let duration = timeEntries.totalDurationInSeconds
        let maxDuration = store.state.workingMinutesPerDay * 60
        let color = timeEntries.isTimerRunning ? UIColor(store.state.accentColor.color) : .gray

        let template = ComplicationProvider(duration: duration,
                                            maxDuration: maxDuration,
                                            color: color)
            .complication(for: complication.family,
                          identifier: ComplicationIdentifier(rawValue: complication.identifier) ?? .standard)

        guard let unwrappedTemplate = template else {
            handler(nil)
            return
        }

        handler(CLKComplicationTimelineEntry(date: Date(),
                                             complicationTemplate: unwrappedTemplate))
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        let now = Date()
        let timeEntries = store.state.timeEntries
        let duration = timeEntries.totalDurationInSeconds
        let maxDuration = store.state.workingMinutesPerDay * 60

        if timeEntries.isTimerRunning {
            var entries: [CLKComplicationTimelineEntry] = []

            for index in 0..<limit {
                let difference = Int(date.timeIntervalSince(now))
                let template = ComplicationProvider(duration: duration + difference + 60 * index,
                                                    maxDuration: maxDuration,
                                                    color: UIColor(store.state.accentColor.color))
                    .complication(for: complication.family,
                                  identifier: ComplicationIdentifier(rawValue: complication.identifier) ?? .standard)

                guard let unwrappedTemplate = template else {
                    handler(nil)
                    return
                }

                let entry = CLKComplicationTimelineEntry(date: date.addingTimeInterval(TimeInterval(60 * index)),
                                                         complicationTemplate: unwrappedTemplate)
                entries.append(entry)
            }

            handler(entries)
        } else {
            handler(nil)
        }
    }

    // MARK: - Sample Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        let template = ComplicationProvider(duration: 12096,
                                            maxDuration: 28800,
                                            color: UIColor(store.state.accentColor.color))
            .complication(for: complication.family,
                          identifier: ComplicationIdentifier(rawValue: complication.identifier) ?? .standard)

        handler(template)
    }
}
