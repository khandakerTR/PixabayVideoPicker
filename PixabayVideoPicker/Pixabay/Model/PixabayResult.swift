//
//  PixabayResult.swift
//  PixabayVideoPicker
//
//  Created by BCL-Device-11 on 16/5/23.
//

import Foundation

struct PixabayResult: Decodable {
    let hits: [PixabayHitModel]
}
