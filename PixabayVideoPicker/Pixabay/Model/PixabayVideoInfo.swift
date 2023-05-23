//
//  PixabayVideoInfo.swift
//  PixabayVideoPicker
//
//  Created by BCL-Device-11 on 16/5/23.
//

import Foundation
// MARK: - Large
class PixabayVideoInfo: Codable {
    
    let url: String
    let width, height, size: Int

    init(url: String, width: Int, height: Int, size: Int) {
        self.url = url
        self.width = width
        self.height = height
        self.size = size
    }
}
