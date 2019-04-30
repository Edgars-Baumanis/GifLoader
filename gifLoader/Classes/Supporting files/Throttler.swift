//
//  Throttler.swift
//  gifLoader
//
//  Created by Edgars Baumanis on 26.04.19.
//  Copyright © 2019. g. chili. All rights reserved.
//

import Foundation

class Throttler {
    private var workItem: DispatchWorkItem = DispatchWorkItem(block: {})
    private var previousRun: Date = Date.distantPast
    private let queue: DispatchQueue = DispatchQueue.global(qos: .background)
    private let minimumDelay: TimeInterval

    init(minimumDelay: TimeInterval) {
        self.minimumDelay = minimumDelay
    }

    func throttle(_ completionHandler: @escaping () -> Void) {
        workItem.cancel()

        workItem = DispatchWorkItem { [weak self] in
            self?.previousRun = Date()
            completionHandler()
        }

        let delay = previousRun.timeIntervalSinceNow > minimumDelay ? 0 : minimumDelay
        queue.asyncAfter(deadline: .now() + Double(delay), execute: workItem)
    }
}
