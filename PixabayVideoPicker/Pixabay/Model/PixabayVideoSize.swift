//
//  PixabayVideoSize.swift
//  PixabayVideoPicker
//
//  Created by BCL-Device-11 on 16/5/23.
//

import Foundation

class PixabayVideoSize: Codable {
    
    let large, medium, small, tiny: PixabayVideoInfo

    init(large: PixabayVideoInfo, medium: PixabayVideoInfo, small: PixabayVideoInfo, tiny: PixabayVideoInfo) {
        self.large = large
        self.medium = medium
        self.small = small
        self.tiny = tiny
    }
}
