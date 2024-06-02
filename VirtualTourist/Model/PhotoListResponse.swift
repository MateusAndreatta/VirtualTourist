//
//  PhotoListResponse.swift
//  VirtualTourist
//
//  Created by Mateus Andreatta on 26/05/24.
//

import Foundation

struct PhotoListResponse: Codable {
    let photos: PhotoResultInfo
    let stat: String
}
