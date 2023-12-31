//
//  Interval.swift
//  ContractionTracker
//
//  Created by Jess on 10/20/23.
//

import Foundation

public extension IntervalStore {
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
        
        public var lengthValue: TimeInterval? {
            guard let end = end, type == .contraction else {
                return nil
            }
            let time = end.timeIntervalSince(start)
            return time
        }
        
        public var length: String {
            return lengthValue?.formattedString ?? ""
        }
        
        public var frequency: String {
            guard let end = end, type == .break else {
                return "   "
            }
            let time = end.timeIntervalSince(start)
            return time.formattedString ?? ""
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
