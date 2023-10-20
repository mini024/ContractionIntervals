//
//  Interval.swift
//  ContractionTracker
//
//  Created by Jess on 10/20/23.
//

import Foundation

public extension IntervalManager {
    class Interval: Codable {
        public let start: Date
        public let type: IntervalType?
        public var end: Date?
        
        public init(start: Date, type: IntervalType?, end: Date? = nil) {
            self.start = start
            self.end = end
            self.type = type
        }
        
        public var id: String {
            start.description
        }
        
        var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            return formatter
        }
        
        var timeFormatter: DateComponentsFormatter {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute,.second]
            formatter.unitsStyle = .abbreviated
            formatter.zeroFormattingBehavior = .pad
            return formatter
        }
        
        public var length: String {
            guard let end = end, type == .contraction else {
                return "   "
            }
            let time = end.timeIntervalSince(start)
            return timeFormatter.string(from: time) ?? ""
        }
        
        public var frequency: String {
            guard let end = end, type == .break else {
                return "   "
            }
            let time = end.timeIntervalSince(start)
            return timeFormatter.string(from: time) ?? ""
        }
        
        public var started: String {
            if let started = type?.started {
                return started
            }

            return dateFormatter.string(from: start)
        }
        
        public var ended: String {
            if let ended = type?.ended {
                return ended
            }
            
            guard let end = end else {
                return ""
            }

            return dateFormatter.string(from: end)
        }
    }
}
