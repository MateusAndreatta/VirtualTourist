//
//  PhotoResultInfo.swift
//  VirtualTourist
//
//  Created by Mateus Andreatta on 26/05/24.
//

import Foundation

struct PhotoResultInfo: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [PhotoData]
}
