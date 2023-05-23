//
//  NSError.swift
//  PixabayVideoPicker
//
//  Created by BCL-Device-11 on 23/5/23.
//

import Foundation

extension NSError {
    func isNoInternetConnectionError() -> Bool {
        let noInternetConnectionErrorCodes = [
            NSURLErrorNetworkConnectionLost,
            NSURLErrorNotConnectedToInternet,
            NSURLErrorInternationalRoamingOff,
            NSURLErrorCallIsActive,
            NSURLErrorDataNotAllowed
        ]

        if domain == NSURLErrorDomain && noInternetConnectionErrorCodes.contains(code) {
            return true
        }

        return false
    }
}

