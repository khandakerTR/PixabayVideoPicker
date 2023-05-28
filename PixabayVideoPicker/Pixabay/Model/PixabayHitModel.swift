//
//  PixabayHitModel.swift
//  PixabayVideoPicker
//
//  Created by BCL-Device-11 on 16/5/23.
//

import Foundation
struct PixabayHitModel: Codable {
    
    let id: Int
    let pageURL: String
    let type: String
    let tags: String
    let duration: Int
    let pictureID: String
    let videos: PixabayVideoSize
    let views, downloads, likes, comments: Int
    let userID: Int
    let user: String
    let userImageURL: String

    enum CodingKeys: String, CodingKey {
        case id, pageURL, type, tags, duration
        case pictureID = "picture_id"
        case videos, views, downloads, likes, comments
        case userID = "user_id"
        case user, userImageURL
    }
}
