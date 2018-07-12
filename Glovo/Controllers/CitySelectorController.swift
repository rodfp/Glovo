//
//  CitySelectorController.swift
//  Glovo
//
//  Created by Rodrigo Franco on 7/10/18.
//

import Foundation
import UIKit
import CoreData

protocol CitySelectorDelegate : class {
  func citySelected(_ city : City)
}

class CitySelectorController : UIViewController{
  
  var countries : [Country]?
  weak var delegate : CitySelectorDelegate?
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCities()
  }
  
  func setupCities(){
    countries = CountryDataHandler.retrieveExistingCountries(withOrderedCities: true)
    self.tableView.reloadData()
  }
  
  @IBAction func close(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
}

extension CitySelectorController : UITableViewDelegate, UITableViewDataSource{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let cities = countries?[section].cities else{ return 0 }
    return cities.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "CityTableViewCell", for: indexPath) as? CityTableViewCell else{
      return UITableViewCell()
    }
    guard let cities = countries?[indexPath.section].cities else{ return UITableViewCell() }
    let citiesArray = cities.allObjects as! [City]
    cell.setupCell(citiesArray[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    guard let countryName = countries?[section].name else { return nil }
    return countryName
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return countries?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cities = countries?[indexPath.section].cities else{ return }
    let citiesArray = cities.allObjects as! [City]
    delegate?.citySelected(citiesArray[indexPath.row])
    self.dismiss(animated: true, completion: nil)
  }
  
}
