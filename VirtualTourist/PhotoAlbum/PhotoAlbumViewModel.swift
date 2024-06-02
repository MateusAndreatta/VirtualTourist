//
//  PhotoAlbumViewModel.swift
//  VirtualTourist
//
//  Created by Mateus Andreatta on 25/05/24.
//

import Foundation
import MapKit
import CoreData

class PhotoAlbumViewModel: NSObject {
    
    var page = 1
    let coordinate: CLLocationCoordinate2D
    let pin: Pin
    var photos: [Photo] = []
    var dataController: DataController?
    
    init(pin: Pin, dataController: DataController?) {
        self.pin = pin
        self.dataController = dataController
        self.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
    }
    
    public func load() {
        setupFetchedResultsController()
    }
    
    func getPhotos(completion: @escaping (Bool) -> Void) {
        FlickrAPI.getPhotos(for: coordinate, page: page) { [weak self] response, error in
            guard let self, error == nil else {
                completion(false)
                return
            }
            page += 1
            if let photosData = response?.photos.photo {
                
                for photo in photos {
                    dataController?.viewContext.delete(photo)
                }
                photos = []
                
                for newPhoto in photosData {
                    if let savedPhoto = savePhoto(with: newPhoto) {
                        photos.append(savedPhoto)
                    }
                }
            }

            completion(true)
        }
    }
    
    public func deletePhoto(at indexPath: IndexPath) {
        let photoToDelete = photos.remove(at: indexPath.row)
        dataController?.viewContext.delete(photoToDelete)
        try? dataController?.viewContext.save()
    }
    
    private func savePhoto(with photoData: PhotoData) -> Photo? {
        guard let dataController else { return nil }
        let photo = Photo(context: dataController.viewContext)
        photo.url = photoData.link
        photo.pin = pin
        try? dataController.viewContext.save()
        return photo
    }
    
    fileprivate func setupFetchedResultsController() {
        guard let dataController else { return }
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "url", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
            if let photosFromCoreData = fetchedResultsController.fetchedObjects {
                photos = photosFromCoreData
            }
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
}

extension PhotoAlbumViewModel: NSFetchedResultsControllerDelegate { }
