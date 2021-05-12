//
//  Schedular.swift
//  UberCarNavigation
//
//  Created by Muhammad Usman on 10/05/2021.
//  
//

import Combine
import Foundation

// MARK: - Class

/// Scheduler class to manage Background Oprations
final class Scheduler {
    static let mainScheduler = RunLoop.main

    static var backgroundWorkScheduler: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = QualityOfService.userInitiated
        return operationQueue
    }()
}
