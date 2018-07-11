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

class MapViewController: UIViewController {

  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var currentLocationButton: UIButton!
  @IBOutlet weak var selectACityButton: UIButton!
  @IBOutlet weak var hideSelectorButton: UIButton!
  @IBOutlet weak var hideInfoButton: UIButton!
  @IBOutlet weak var currencyLabel: UILabel!
  @IBOutlet weak var timeZoneLabel: UILabel!
  @IBOutlet weak var languageLabel: UILabel!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    RequestManager.shared.getAllCountries { _ in
      let countries = CountryDataHandler.retrieveExistingCountries()
      for country in countries {
        print("Country: \(country.name), code: \(country.code)")
      }
      RequestManager.shared.getAllCities{ _ in
        let cities = CityDataHandler.retrieveExistingCities()
        for city in cities {
          print("City: \(city.name), code: \(city.code), country: \(city.country?.name)")
          let coordinate = GMSPath(fromEncodedPath: city.workingArea![0])?.coordinate(at: 0)
          let camera = GMSCameraPosition.camera(withLatitude: coordinate!.latitude, longitude: coordinate!.longitude, zoom: 6.0)
          self.mapView.camera = camera
          let marker = GMSMarker()
          marker.position = CLLocationCoordinate2D(latitude: coordinate!.latitude, longitude: coordinate!.longitude)
          marker.title = "Sydney"
          marker.snippet = "Australia"
          marker.map = self.mapView
          for area in city.workingArea! {
            let polygon = GMSPolygon(path: GMSPath(fromEncodedPath: area))
            polygon.map = self.mapView
          }
        }
      }
    }
  }
  
  @IBAction func currentLocationAction(_ sender: Any) {
    
  }
  
  @IBAction func selectACityAction(_ sender: Any) {
    self.performSegue(withIdentifier: "selectCity", sender: nil)
  }
  
  @IBAction func selectorTapped(_ sender: Any) {
    
  }
  
  @IBAction func infoButtonTapped(_ sender: Any) {
    
  }
  
  
}

extension MapViewController : GMSMapViewDelegate{
  
}

