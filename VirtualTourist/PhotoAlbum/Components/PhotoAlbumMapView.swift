//
//  PhotoAlbumMapView.swift
//  VirtualTourist
//
//  Created by Mateus Andreatta on 25/05/24.
//

import Foundation
import UIKit
import MapKit

class PhotoAlbumMapView: UIView {
    
    private lazy var mkMapView: MKMapView = {
        let mkMapView = MKMapView()
        mkMapView.translatesAutoresizingMaskIntoConstraints = false
        mkMapView.delegate = self
        return mkMapView
    }()

    init() {
        super.init(frame: .zero)
        constraintUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func constraintUI() {
        addSubview(mkMapView)

        NSLayoutConstraint.activate([
            mkMapView.topAnchor.constraint(equalTo: topAnchor),
            mkMapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mkMapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mkMapView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    public func setup(for coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mkMapView.addAnnotation(annotation)
        mkMapView.setCenter(coordinate, animated: false)
        let zoomRange = MKMapView.CameraZoomRange(minCenterCoordinateDistance: 1000, maxCenterCoordinateDistance: 100000)
        mkMapView.setCameraZoomRange(zoomRange, animated: true)
    }
    
}

extension PhotoAlbumMapView: MKMapViewDelegate {
    
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
        
}
