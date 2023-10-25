//
//  File.swift
//  
//
//  Created by Jess on 10/25/23.
//

import Foundation

public final class IntervalMetricsHelper {
    
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
    
    private static func frequencyInBetween(_ start: Date, _ end: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute,.second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        
        let time = end.timeIntervalSince(start)
        return formatter.string(from: time) ?? ""
    }
    
    // MARK: MinMax Frequency
    public static func getMinMaxFrecuency(for intervals: [IntervalStore.Interval]) -> (String, String)? {
        var min: TimeInterval?
        var max: TimeInterval?
        let previousIntervals: [IntervalStore.Interval?] = [nil] + intervals
        for (previous, current) in zip(previousIntervals, intervals) {
            if let previous = previous {
                let frequency = current.start.timeIntervalSince(previous.start)
                
                if min == nil || frequency < min! {
                    min = frequency
                }
                
                if max == nil || frequency > max! {
                    max = frequency
                }
            }
        }
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute,.second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        
        if let min = min, let max = max, let formattedMin = formatter.string(from: min), let formattedMax = formatter.string(from: max) {
            return (formattedMin, formattedMax)
        }
        
        return nil
    }

}
