//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Mateus Andreatta on 25/05/24.
//

import Foundation
import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, UIGestureRecognizerDelegate {
    
    weak var dataController: DataController?
    
    private lazy var mkMapView: MKMapView = {
        let mkMapView = MKMapView()
        mkMapView.translatesAutoresizingMaskIntoConstraints = false
        mkMapView.delegate = self
        return mkMapView
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        constraintUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        self.mkMapView.addGestureRecognizer(lpgr)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    func constraintUI() {
        view.addSubview(mkMapView)
        
        NSLayoutConstraint.activate([
            mkMapView.topAnchor.constraint(equalTo: view.topAnchor),
            mkMapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mkMapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mkMapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != UIGestureRecognizer.State.ended {
            return
        }
        else if gestureRecognizer.state != UIGestureRecognizer.State.began {
            
            let touchPoint = gestureRecognizer.location(in: self.mkMapView)
            
            let touchMapCoordinate =  self.mkMapView.convert(touchPoint, toCoordinateFrom: mkMapView)

            if let pin = savePin(with: touchMapCoordinate) {
                let annotation = PinAnnotation(pin: pin)
                annotation.coordinate = touchMapCoordinate
                self.mkMapView.addAnnotation(annotation)
            }
        }
    }
    
    private func savePin(with coordinate: CLLocationCoordinate2D) -> Pin? {
        guard let dataController else { return nil }
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        try? dataController.viewContext.save()
        return pin
    }
    
    fileprivate func setupFetchedResultsController() {
        guard let dataController else { return }
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            if let pins = fetchedResultsController.fetchedObjects {
                addPins(pins)
            }
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    private func addPins(_ pins: [Pin]) {
        var annotations: [PinAnnotation] = []
        for pin in pins {
            annotations.append(PinAnnotation(pin: pin))
        }
        self.mkMapView.addAnnotations(annotations)
    }
}

extension TravelLocationsMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView {
            annotationView.annotation = annotation
            return annotationView
        }
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        annotationView.markerTintColor = .red
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard view.annotation is PinAnnotation else {
            return
        }
        let pinAnnotation = view.annotation as? PinAnnotation
        if let pin = pinAnnotation?.pin {
            let photosViewController = PhotoAlbumViewController(viewModel: PhotoAlbumViewModel(pin: pin, dataController: dataController))
            navigationController?.pushViewController(photosViewController, animated: true)
        }
    }
    
}

extension TravelLocationsMapViewController: NSFetchedResultsControllerDelegate {
    
}
