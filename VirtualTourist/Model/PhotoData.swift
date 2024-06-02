//
//  Photo.swift
//  VirtualTourist
//
//  Created by Mateus Andreatta on 26/05/24.
//

import Foundation

struct PhotoData: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}

extension PhotoData {
    var link: String {
       "https://live.staticflickr.com/\(server)/\(id)_\(secret).jpg"
    }
}
