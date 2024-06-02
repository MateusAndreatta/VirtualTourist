//
//  PinAnnotation.swift
//  VirtualTourist
//
//  Created by Mateus Andreatta on 01/06/24.
//

import Foundation
import MapKit

class PinAnnotation: MKPointAnnotation {

    let pin: Pin

    init(pin: Pin) {
        self.pin = pin
        super.init()
        self.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
    }
}
