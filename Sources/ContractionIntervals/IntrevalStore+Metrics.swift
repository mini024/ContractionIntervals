//
//  File.swift
//  
//
//  Created by Jess on 10/25/23.
//

import Foundation

public final class IntervalMetricsHelper {
    
    public struct MinMax {
        public let minValue: TimeInterval
        public let maxValue: TimeInterval
        
        public var min: String {
            minValue.formattedString ?? ""
        }
        
        public var max: String {
            maxValue.formattedString ?? ""
        }
    }
    
    // MARK: - Frequency
    
    // MARK: Last Frequency
    public static func getLastFrecuency(for intervals: [IntervalStore.Interval]) -> String? {
        let lastIndex = intervals.count - 1
        if lastIndex > 1 {
            let last = intervals[lastIndex]
            let secondToLast = intervals[lastIndex - 1]
            
            return frequencyInBetween(secondToLast.start, last.start)
        }
        
        return nil
    }
    
    public static func frequencyInBetween(_ start: Date, _ end: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute,.second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        
        let time = end.timeIntervalSince(start)
        return formatter.string(from: time) ?? ""
    }
    
    // MARK: Last Hour MinMax Frequency
    public static func getLastHourMinMaxFrequency(for intervals: [IntervalStore.Interval]) -> MinMax? {
        let lastHourIntervals = intervals.filter({ $0.start.timeIntervalSinceNow > -3600 })
        return getMinMaxFrecuency(for: lastHourIntervals)
    }
    
    // MARK: Frequencies for Intervals
    static func getFrequencies(for intervals: [IntervalStore.Interval]) -> [TimeInterval] {
        var result: [TimeInterval] = []
        let previousIntervals: [IntervalStore.Interval?] = [nil] + intervals
        for (previous, current) in zip(previousIntervals, intervals) {
            if let previous = previous {
                let frequency = current.start.timeIntervalSince(previous.start)
                
                if frequency < 0 {
                    print("--- Negative frequency")
                    continue
                }
                
                result.append(frequency)
            }
        }
        
        return result
    }
    
    // MARK: MinMax Frequency
    /// Calculate the min and max time in between intervals
    /// - Parameter intervals: All intervals to consider, most contain a start date.
    /// - Returns: `MinMax` object, where the min and max are time interval strings.
    static func getMinMaxFrecuency(for intervals: [IntervalStore.Interval]) -> MinMax? {
        var frequencies = getFrequencies(for: intervals)
        var min: TimeInterval? = frequencies.min()
        var max: TimeInterval? = frequencies.max()
    
        if let min = min, let max = max {
            return MinMax(minValue: min, maxValue: max)
        }
        
        return nil
    }
    
    // MARK: Mean Frequency
    static func getFrecuencyLengthMean(for intervals: [IntervalStore.Interval]) -> TimeInterval {
        let values = getFrequencies(for: intervals)
        let sum = values.reduce(0, +)
        let total = Double(values.count)
        
        return sum / total
    }
    
    // MARK: - Contractions

    // MARK: Last Contraction Length
    static public func getLastContractionLength(for intervals: [IntervalStore.Interval]) -> String? {
        guard let last = intervals.last else {
            return nil
        }
        
        return last.length
    }
    
    // MARK: MinMax Contraction Length for last hour
    static public func getMinMaxContractionLength(for intervals: [IntervalStore.Interval]) -> MinMax? {
        let lastHourIntervals = intervals.filter({ $0.start.timeIntervalSinceNow > -3600 }).compactMap { $0.lengthValue }
        if let min = lastHourIntervals.min(), let max = lastHourIntervals.max() {
            return MinMax(minValue: min, maxValue: max)
        }

        return nil
    }
    
    // MARK: Mean of contractions
    static func getContractionLengthMean(for intervals: [IntervalStore.Interval]) -> TimeInterval {
        let values = intervals.compactMap { $0.lengthValue }
        let sum = values.reduce(0, { $0 + $1 })
        let total = values.count
        
        return sum / Double(total)
    }
    
    // MARK: - Other
    
    // MARK: Calculate go to hospital
    static public func shouldShowHospitalAlert(for intervals: [IntervalStore.Interval]) -> Bool {
        // Contractions longer than 45 seconds every 4/5 minutes
        if getContractionLengthMean(for: intervals) > 45 && getFrecuencyLengthMean(for: intervals) < 300 {
            return true
        }
        
        return false
    }

}

extension TimeInterval {
    var formattedString: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute,.second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        
        return formatter.string(from: self)
    }
}
