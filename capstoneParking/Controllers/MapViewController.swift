//
//  MapViewController.swift
//  capstoneParking
//
//  Created by Justin Snider on 3/22/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AVFoundation

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate {
    
    //==================================================
    // MARK: - Properties
    //==================================================
    
    private var locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    let steps = [MKRoute.Step]()
    let speechSynthesizer = AVSpeechSynthesizer()
    var resultSearchController: UISearchController? = nil
    var selectedPin:MKPlacemark? = nil

    //Outlets
    @IBOutlet var backgroundUIView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var customAlertControllerStackview: UIStackView!
    @IBOutlet weak var registerSpotUIView: UIView!
    @IBOutlet weak var registerUIView: UIView!
    @IBOutlet weak var cancelUIView: UIView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var stopAndGoStackView: UIStackView!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var stopDirectionsButton: UIButton!
    
    
    //==================================================
    // MARK: - View LifeCycle
    //==================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestAuthorizations()
        setInitialMapProperties()
        
        
        if let coor = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coor, animated: true)
        }
        
        customAlertControllerStackview.transform = CGAffineTransform(translationX: 0, y: 210)
        stopAndGoStackView.transform = CGAffineTransform(translationX: 160, y: 0)
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search desired area"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self

        
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        registerSpotUIView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
        registerUIView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10.0)
    }
    
    //==================================================
    // MARK: - Functions - View and Layout
    //==================================================
    
    
    
    func showCustomAlertController() {
        UIView.animate(withDuration: 0.3) {
            self.customAlertControllerStackview.transform = CGAffineTransform(translationX: 0, y: 0)
            self.mapView.alpha = 0.6
            self.backgroundUIView.backgroundColor = #colorLiteral(red: 0.6059342617, green: 0.6059342617, blue: 0.6059342617, alpha: 1)
        }
        self.mapView.isUserInteractionEnabled = false

    }
    
    func hideCustomAlertController() {
        UIView.animate(withDuration: 0.3) {
            self.customAlertControllerStackview.transform = CGAffineTransform(translationX: 0, y: 210)
            self.mapView.alpha = 1.0
            self.backgroundUIView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        self.mapView.isUserInteractionEnabled = true
    }
    
    func showStopAndGoStackView() {
        UIView.animate(withDuration: 0.2, animations: {
            self.stopAndGoStackView.transform = CGAffineTransform(translationX: -20, y: 0)
        }) { (true) in
            UIView.animate(withDuration: 0.1, animations: {
                self.stopAndGoStackView.transform = CGAffineTransform(translationX: 10, y: 0)
            })
        }
    }
    
    func hideStopAndGoStackView() {
        UIView.animate(withDuration: 0.1) {
            self.stopAndGoStackView.transform = CGAffineTransform(translationX: 160, y: 0)
        }
    }
    
    //==================================================
    // MARK: - Functions - MapKit
    //==================================================

    func requestAuthorizations() {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
        }
    }
    
    func setInitialMapProperties() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        mapView.delegate = self
        mapView.showsScale = true
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        
        if let coordinate = mapView.userLocation.location?.coordinate {
            mapView.setCenter(coordinate, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue: CLLocationCoordinate2D = manager.location!.coordinate
        
        mapView.mapType = MKMapType.standard
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: locValue, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func showPolylineOverlay() {
        guard let sourceCoordinate = locationManager.location?.coordinate,
            //Is the pin the FIRST or LAST item in the array?!!!!!!!
            let destination = mapView.annotations.last else { return }
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destination.coordinate)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceItem
        directionRequest.destination = destinationItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate(completionHandler: { response, error in
            guard let response = response else {
                    print("Error occured while calculating directions")
                return
            }
            
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            let edgePadding = UIEdgeInsets(top: 100, left: 20, bottom: 40, right: 20)
            self.mapView.setVisibleMapRect(rect, edgePadding: edgePadding, animated: true)
        })
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 10.0
        
        return renderer
    }
    
    func removeMapViewOverlays() {
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let point = CGPoint(x: 0, y: 0)
        let button = UIButton(frame: CGRect(origin: point, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), for: .normal)
        button.addTarget(self, action: #selector(MapViewController.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
    
    @objc func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    //==================================================
    // MARK: - Actions
    //==================================================
    
    @IBAction func registerButtonTapped(_ sender: Any) {
//        showDirectionsLabel()
        hideCustomAlertController()
//        self.getDirections()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        hideCustomAlertController()
        
//        guard let newestAnnotation = mapView.annotations.last else { return }
        self.mapView.removeAnnotations(mapView.annotations)
        
        removeMapViewOverlays()
    }
    
    @IBAction func userDidLongPress(_ sender: UILongPressGestureRecognizer) {
        showCustomAlertController()
        
        let location = sender.location(in: self.mapView)
        let locationCoordinate = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        annotation.title = "New Parking Spot"
        
//        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.addAnnotation(annotation)
    }
    
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        self.showPolylineOverlay()
//        showStopAndGoStackView()
//    }
    
    @IBAction func goButtonTapped(_ sender: Any) {
        
    }
    @IBAction func stopButtonTapped(_ sender: Any) {
        removeMapViewOverlays()
        hideStopAndGoStackView()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MapViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "(city) (state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
}
    

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}


