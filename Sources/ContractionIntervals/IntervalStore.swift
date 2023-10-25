//
//  ContractionManager.swift
//  ContractionTracker
//
//  Created by Jess on 10/6/23.
//

import UIKit
import Boutique
import Foundation

extension Store where Item == IntervalStore.Interval {
    static let intervalStore = Store<IntervalStore.Interval>(
        storage: SQLiteStorageEngine.default(appendingPath: "Intervals"),
        cacheIdentifier: \.start.description
    )
}

public class IntervalStore: ObservableObject {
    public static let shared = IntervalStore()
    
    @Stored(in: .intervalStore)
    public var intervals: [Interval]
    
    @StoredValue(key: "currentInterval")
    public var currentInterval: Interval? = nil
            
    public var isTrackingContraction: Bool {
        currentInterval?.type == .contraction
    }
    
    private init() {
        Task {
            await migrateIntervals()
        }
    }
    
    /// Clear .break type intervals.
    func migrateIntervals() async {
        let oldIntervals = await intervals
        guard !oldIntervals.isEmpty else { return }
        
        do {
            let migratedIntervals = oldIntervals.filter({ $0.type == .contraction })
            try await self.$intervals.removeAll().insert(migratedIntervals).run()
        } catch {
            print(error)
            print("--- Failed to migrate intervals")
        }
    }
    
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
            do {
                try await self.$intervals.insert(currentInterval)
            } catch {
                print(error)
            }
            await self.$currentInterval.set(nil)
        } else {
            print("Tried to end interval that hasn't started")
        }
    }
    
#if DEBUG
    public func addTestData() async {
        await reset()
        if !ProcessInfo.processInfo.arguments.contains("CLEAR_TEST") {
            let durations = [75, 35, 50, 50, 55, 45, 60, 58, 63, 50]
            let frequencies = [10 * 60, 9 * 60, 9 * 60, 8 * 60, 8 * 60, 8 * 60, 8 * 60, 7 * 60, 5 * 60, 3 * 60]
            let totalTime = durations.reduce(0, { $0 + $1 }) + frequencies.reduce(0, { $0 + $1 })
            var currentDate = Calendar.current.date(byAdding: DateComponents(second: -totalTime), to: Date()) ?? Date()
            for (duration, frequency) in zip(durations, frequencies) {
                if let end = Calendar.current.date(byAdding: DateComponents(second: duration), to: currentDate), let nextDate = Calendar.current.date(byAdding: DateComponents(second: frequency), to: end) {
                    do {
                        try await self.$intervals.insert(Interval(start: currentDate, type: .contraction, end: end))
                        currentDate = nextDate
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
#endif
}
