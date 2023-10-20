//
//  ContractionManager.swift
//  ContractionTracker
//
//  Created by Jess on 10/6/23.
//

import UIKit
import Boutique
import Foundation

extension Store where Item == IntervalManager.Interval {
    static let invervalStore = Store<IntervalManager.Interval>(
        storage: SQLiteStorageEngine.default(appendingPath: "Intervals"),
        cacheIdentifier: \.start.description
    )
}

public class IntervalManager: ObservableObject {
    public static let shared = IntervalManager()
    
    
    @Stored(in: .invervalStore)
    public var intervals: [Interval]
    
    @StoredValue(key: "currentInterval")
    public var currentInterval: Interval? = nil
            
    public var isTrackingContraction: Bool {
        currentInterval?.type == .contraction
    }
        
#if DEBUG
    public func addTestData() async {
        await reset()
        if !ProcessInfo.processInfo.arguments.contains("CLEAR_TEST") {
            let durations = [30, 10 * 60, 35, 9 * 60, 50, 9 * 60, 50, 8 * 60, 55, 8 * 60, 45, 8 * 60, 60, 8 * 60, 58, 7 * 60, 63, 7 * 60, 50]
            let totalDurations = durations.reduce(0, { $0 + $1 })
            var currentDate = Calendar.current.date(byAdding: DateComponents(second: -totalDurations), to: Date()) ?? Date()
            for i in 0..<durations.count {
                var interval: Interval?
                let duration = durations[i]
                if i % 2 == 0 {
                    // Contraction
                    if let end = Calendar.current.date(byAdding: DateComponents(second: duration), to: currentDate) {
                        interval = Interval(start: currentDate, type: .contraction, end: end)
                        currentDate = end
                    }
                } else {
                    // Break
                    if let end = Calendar.current.date(byAdding: DateComponents(second: duration), to: currentDate) {
                        interval = Interval(start: currentDate, type: .break, end: end)
                        currentDate = end
                    }
                }
                
                if let interval = interval {
                    try? await self.$intervals.insert(interval)
                }
            }
        }
    }
#endif
    
    public func reset() async {
        try? await self.$intervals.removeAll()
        await $currentInterval.reset()
    }
    
    public func startEndContraction() async {
        if isTrackingContraction {
            // End Contraction
            await endContraction(at: Date())
        } else {
            await startContraction(at: Date())
        }
    }
    
    private func startContraction(at date: Date) async {
        guard currentInterval == nil else {
            print("Tried to start contraction when contraction was already ongoing")
            return
        }
        
        // Start contraction
        await $currentInterval.set(Interval(start: date, type: .contraction))
    }
    
    private func endContraction(at date: Date) async {
        if let currentInterval = currentInterval {
            currentInterval.end = date

            if let lastInterval = await self.$intervals.items.last, lastInterval.type == .contraction, let lastIntervalEnd = lastInterval.end {
                let inBetween = Interval(start: lastIntervalEnd, type: .break, end: currentInterval.start)
                
                try? await self.$intervals
                            .insert(inBetween)
                            .insert(currentInterval)
                            .run()
            } else {
                try? await self.$intervals.insert(currentInterval)
            }
        
            await self.$currentInterval.set(nil)
        } else {
            print("Tried to end interval that hasn't started")
        }
    }
}
