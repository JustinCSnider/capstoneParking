//
//  SearchResultMKMapItem.swift
//  capstoneParking
//
//  Created by Douglas Patterson on 4/30/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import Foundation
import MapKit

class SearchResultAnnotation: NSObject, MKAnnotation {
    
    let annotation: MKAnnotation
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    let isSearchResult: Bool

    init(annotation: MKAnnotation, searchResult: Bool, coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.isSearchResult = searchResult
        self.annotation = annotation
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}

class ParkingSpotAnnotation: NSObject, MKAnnotation {
    
    let annotation: MKAnnotation
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?

    init(annotation: MKAnnotation, coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.annotation = annotation
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
}

