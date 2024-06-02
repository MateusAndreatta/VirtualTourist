//
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by Mateus Andreatta on 26/05/24.
//

import Foundation
import MapKit

enum FlickrAPI {
    
    enum Endpoints {
        case getPhotosList(CLLocationCoordinate2D, Int)
        
        var API_KEY: String { "0d1e6d4ff1a300b8fe09afb8f1885392" }
        
        var path: String {
           switch self {
           case .getPhotosList(let coordinates, let page):
               return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&format=json&nojsoncallback=1&per_page=15&page=\(page)"
           }
       }
       
       var url: URL {
           return URL(string: "\(path)")!
       }
    }
    
    static func getPhotos(for coordinates: CLLocationCoordinate2D, page: Int, completion: @escaping (PhotoListResponse?, Error?) -> Void) {
        let request = URLRequest(url: Endpoints.getPhotosList(coordinates, page).url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            if let data, let responseObject = try? decoder.decode(PhotoListResponse.self, from: data) {
                DispatchQueue.main.async {
                    completion(responseObject, error)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
}
