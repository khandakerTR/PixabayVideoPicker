//
//  ConcurrentOperation.swift
//  PixabayVideoPicker
//
//  Created by BCL-Device-11 on 17/5/23.
//

import UIKit

class ConcurrentOperation: Operation {

    var error: Error?

    override init() {
        overrideExecuting = false
        overrideFinished = false

        super.init()
    }

    override func start() {
        isExecuting = true

        if isCancelled || hasCancelledDependency() {
            cancel()
            completeOperation()
            return
        }

        main()
    }

    func completeOperation() {
        isExecuting = false
        isFinished = true
    }

    final func completeWithError(_ error: Error) {
        self.error = error
        cancelAndCompleteOperation()
    }

    func cancelAndCompleteOperation() {
        cancel()
        completeOperation()
    }

    private var overrideExecuting: Bool
    override var isExecuting: Bool {
        get { return overrideExecuting }
        set {
            willChangeValue(forKey: "isExecuting")
            overrideExecuting = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }

    private var overrideFinished: Bool
    override var isFinished: Bool {
        get { return overrideFinished }
        set {
            willChangeValue(forKey: "isFinished")
            overrideFinished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
}

extension Operation {
    func hasCancelledDependency() -> Bool {
        for operation in dependencies where operation.isCancelled { return true }
        return false
    }
}

