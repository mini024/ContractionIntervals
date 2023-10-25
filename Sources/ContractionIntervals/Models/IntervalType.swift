//
//  IntervalType.swift
//  ContractionTracker
//
//  Created by Jess on 10/20/23.
//

import Foundation

extension IntervalStore {
    public enum IntervalType: Codable {
        case contraction
        case `break`
        
        var started: String? {
            switch self {
            case .break:
                return "Break"
            case .contraction:
                return nil
            }
        }
        
        var ended: String? {
            switch self {
            case .break:
                return "---"
            case .contraction:
                return nil
            }
        }
        
        var title: String {
            switch self {
            case .contraction:
                "Contraction"
            case .break:
                "Break"
            }
        }
    }
}
