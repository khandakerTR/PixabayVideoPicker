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

//    init(id: Int, pageURL: String, type: String, tags: String, duration: Int, pictureID: String, videos: PixabayVideo, views: Int, downloads: Int, likes: Int, comments: Int, userID: Int, user: String, userImageURL: String) {
//        self.id = id
//        print("ID ",id)
//        self.pageURL = pageURL
//        self.type = type
//        self.tags = tags
//        self.duration = duration
//        self.pictureID = pictureID
//        self.videos = videos
//        self.views = views
//        self.downloads = downloads
//        self.likes = likes
//        self.comments = comments
//        self.userID = userID
//        self.user = user
//        self.userImageURL = userImageURL
//    }
}
