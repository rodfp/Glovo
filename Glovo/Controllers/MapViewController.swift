//
//  MapViewController.swift
//  Glovo
//
//  Created by Rodrigo Franco on 7/10/18.
//

import UIKit
import SwiftyJSON
import CoreData
import GoogleMaps

// Values taken from: https://developers.google.com/maps/documentation/ios-sdk/views
enum MapsZoom : Float {
  case world = 1.0
  case landmass = 5.0
  case city = 10.0
  case streets = 15.0
  case buildings = 20.0
}

class MapViewController: UIViewController {

  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var currentLocationButton: UIButton!
  @IBOutlet weak var selectACityButton: UIButton!
  @IBOutlet weak var hideSelectorButton: UIButton!
  @IBOutlet weak var hideInfoButton: UIButton!
  @IBOutlet weak var currencyLabel: UILabel!
  @IBOutlet weak var timeZoneLabel: UILabel!
  @IBOutlet weak var languageLabel: UILabel!
  @IBOutlet weak var cityNameLabel: UILabel!
  @IBOutlet weak var infoConstraintHeight: NSLayoutConstraint!
  @IBOutlet weak var selectorConstraintHeight: NSLayoutConstraint!
  @IBOutlet weak var infoView: UIView!
  
  var cities : [City]?
  let normalInfoHeight : CGFloat = 170.0
  let shortInfoHeight : CGFloat = 80.0
  let normalSelectorHeight : CGFloat = 160.0
  let shortSelectorHeight : CGFloat = 40.0
  var locationManager: CLLocationManager!
  var currentLocation : CLLocation?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupApp()
    NotificationCenter.default.addObserver(self, selector: #selector(startLocation), name: .locationPermissionUpdated, object: nil)
  }
  
  private func setupApp(){
    RequestManager.shared.getAllCountries { _ in
      RequestManager.shared.getAllCities{ _ in
        self.cities = CityDataHandler.retrieveExistingCities()
        self.setupAllMarkersInMap()
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let dest = segue.destination as? CitySelectorController {
      dest.delegate = self
    }
  }
  
  private func checkForCurrentLocation(){
    if PermissionsManager.shared.locationGranted == nil{
      PermissionsManager.shared.requestLocationPermission()
    }else{
      self.startLocation()
    }
  }
  
  @IBAction func currentLocationAction(_ sender: Any) {
    checkForCurrentLocation()
  }
  
  @objc fileprivate func startLocation(){
    if PermissionsManager.shared.locationGranted == true{
      self.locationManager = CLLocationManager()
      self.locationManager.delegate = self
      self.locationManager.startUpdatingLocation()
    }else{
      print("No permissions granted =(")
    }
  }
  
  @IBAction func selectACityAction(_ sender: Any) {
    self.performSegue(withIdentifier: "selectCity", sender: nil)
  }
  
  @IBAction func selectorTapped(_ sender: Any) {
    if selectorConstraintHeight.constant == normalSelectorHeight{
      hideSelectorButton.setTitle("SHOW SELECTOR", for: .normal)
      currentLocationButton.isHidden = true
      selectACityButton.isHidden = true
      UIView.animate(withDuration: 0.2) {
        self.view.layoutIfNeeded()
      }
      selectorConstraintHeight.constant = shortSelectorHeight
    }else{
      hideSelectorButton.setTitle("HIDE SELECTOR", for: .normal)
      UIView.animate(withDuration: 0.2) {
        self.view.layoutIfNeeded()
        self.currentLocationButton.isHidden = false
        self.selectACityButton.isHidden = false
      }
      selectorConstraintHeight.constant = normalSelectorHeight
    }
  }
  
  @IBAction func infoButtonTapped(_ sender: Any) {
    if infoConstraintHeight.constant == normalInfoHeight{
      hideInfoButton.setTitle("SHOW INFO", for: .normal)
      currencyLabel.isHidden = true
      languageLabel.isHidden = true
      timeZoneLabel.isHidden = true
      UIView.animate(withDuration: 0.2) {
        self.view.layoutIfNeeded()
      }
      infoConstraintHeight.constant = shortInfoHeight
    }else{
      hideInfoButton.setTitle("HIDE INFO", for: .normal)
      UIView.animate(withDuration: 0.2) {
        self.view.layoutIfNeeded()
        self.currencyLabel.isHidden = false
        self.languageLabel.isHidden = false
        self.timeZoneLabel.isHidden = false
      }
      infoConstraintHeight.constant = normalInfoHeight
    }
  }
  
  fileprivate func setupCityDetails(_ updatedCity : City?){
    guard let updatedCity = updatedCity else {
      self.cityNameLabel.text = "Drag the map to a supported city"
      self.currencyLabel.text = "Currency: N/A"
      self.languageLabel.text = "Language: N/A"
      self.timeZoneLabel.text = "Time zone: N/A"
      return
    }
    self.cityNameLabel.text = "\(updatedCity.name!), \(updatedCity.country!.name!)"
    self.currencyLabel.text = updatedCity.currency != nil ? "Currency: \(updatedCity.currency!)" : "Currency: N/A"
    self.languageLabel.text = updatedCity.languageCode != nil ? "Language: \(updatedCity.languageCode!)" : "Language: N/A"
    self.timeZoneLabel.text = updatedCity.timeZone != nil ? "Time zone: \(updatedCity.timeZone!)" : "Time zone: N/A"
  }
  
  fileprivate func zoomToCity(_ city : City){
    guard let workingArea = city.workingArea else{ return }
    let index = workingArea.count / 2
    let pointToDecode = workingArea[index]
    guard let path = GMSPath(fromEncodedPath: pointToDecode) else{ return }
    let coordinate = path.coordinate(at: 0)
    drawWorkingAreaForCity(city)
    let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: MapsZoom.city.rawValue)
    self.mapView.camera = camera
  }
  
  fileprivate func setupAllMarkersInMap(){
    guard let cities = self.cities else { return }
    self.removeEverythingInMap()
    for city in cities {
      guard let workingArea = city.workingArea else{ break }
      let index = workingArea.count / 2
      let pointToDecode = workingArea[index]
      guard let path = GMSPath(fromEncodedPath: pointToDecode) else{ break }
      let coordinate = path.coordinate(at: 0)
      let marker = CityMarker()
      marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
      marker.city = city
      marker.map = self.mapView
    }
  }
  
  fileprivate func drawWorkingAreaForCity(_ city : City){
    self.removeEverythingInMap()
    guard let workingArea = city.workingArea else{ return }
    for area in workingArea {
      let polygon = GMSPolygon(path: GMSPath(fromEncodedPath: area))
      polygon.map = self.mapView
    }
  }
  
  fileprivate func removeEverythingInMap(){
    self.mapView.clear()
  }
  
  fileprivate func cityOfCurrentPosition(position: CLLocationCoordinate2D) -> City?{
    guard let cities = self.cities else { return nil }
    for city in cities{
      guard let workingArea = city.workingArea else { break }
      for area in workingArea{
        guard let polygonPath = GMSPath(fromEncodedPath: area) else { break }
        if GMSGeometryContainsLocation(position, polygonPath, true){ return city }
      }
    }
    return nil
  }
  
  fileprivate func updateCityIfNeededAndSetupDetails(_ city : City){
    guard let code = city.code else { return }
    let cityNeedsUpdate = city.currency == nil || city.timeZone == nil || city.languageCode == nil
    if cityNeedsUpdate{
      RequestManager.shared.getCityDetails(code) { _ in
        guard let city = CityDataHandler.returnExistingCity(code: code) else { return }
        self.setupCityDetails(city)
      }
    }else{
      self.setupCityDetails(city)
    }
  }
  
}

extension MapViewController : CLLocationManagerDelegate{
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location: CLLocation = locations.last else { return }
    locationManager.stopUpdatingLocation()
    guard let city = self.cityOfCurrentPosition(position: location.coordinate) else{
      let alert = UIAlertController(title: "City not supported", message: "Your city is currently not supported.", preferredStyle: .alert)
      let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      alert.addAction(okAction)
      self.present(alert, animated: true, completion: nil)
      return
    }
    updateCityIfNeededAndSetupDetails(city)
    zoomToCity(city)
  }
}

extension MapViewController : GMSMapViewDelegate{
  
  func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
    if let cityMarker = marker as? CityMarker {
      self.zoomToCity(cityMarker.city!)
    }
    return true
  }
  
  func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
    if position.zoom >= MapsZoom.city.rawValue{
      guard let city = cityOfCurrentPosition(position: position.target) else {
        setupCityDetails(nil)
        return
      }
      drawWorkingAreaForCity(city)
      updateCityIfNeededAndSetupDetails(city)
    }else{
      setupAllMarkersInMap()
    }
  }
}

extension MapViewController : CitySelectorDelegate {
  
  func citySelected(_ city: City) {
    guard let code = city.code else { return }
    RequestManager.shared.getCityDetails(code) { _ in
      guard let updatedCity = CityDataHandler.returnExistingCity(code: code) else { return }
      self.setupCityDetails(updatedCity)
      self.zoomToCity(updatedCity)
    }
  }
  
}

