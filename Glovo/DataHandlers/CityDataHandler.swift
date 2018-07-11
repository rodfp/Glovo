//
//  CityDataHandler.swift
//  Glovo
//
//  Created by Rodrigo Franco on 7/10/18.
//

import Foundation
import CoreData
import UIKit
import SwiftyJSON

class CityDataHandler : NSObject {
  
  static func saveCity(_ json : JSON){
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let context = appDelegate.persistentContainer.viewContext
    let code = json["code"].stringValue
    let name = json["name"].stringValue
    let countryCode = json["country_code"].stringValue
    let workingArea = json["working_area"].arrayValue.map { $0.stringValue }
    let currency = json["currency"].string
    let enabled = json["enabled"].bool
    let timeZone = json["time_zone"].string
    let busy = json["busy"].bool
    let languageCode = json["language_code"].string
    
    if let existingCity = returnExistingCity(code: code) {
      existingCity.code = code
      existingCity.name = name
      let country = CountryDataHandler.returnExistingCountry(code: countryCode)
      existingCity.country = country
      existingCity.workingArea = workingArea
      existingCity.currency = currency != nil ? currency! : existingCity.currency
      existingCity.enabled = enabled != nil ? enabled! : existingCity.enabled
      existingCity.timeZone = timeZone != nil ? timeZone! : existingCity.timeZone
      existingCity.busy = busy != nil ? busy! : existingCity.busy
      existingCity.languageCode = languageCode != nil ? languageCode! : existingCity.languageCode
    }else{
      guard let city = NSEntityDescription.entity(forEntityName: "City", in: context) else { return }
      guard let newCity = NSManagedObject(entity: city, insertInto: context) as? City else { return }
      newCity.code = code
      newCity.name = name
      let country = CountryDataHandler.returnExistingCountry(code: countryCode)
      newCity.country = country
      newCity.workingArea = workingArea
      newCity.currency = currency != nil ? currency! : newCity.currency
      newCity.enabled = enabled != nil ? enabled! : newCity.enabled
      newCity.timeZone = timeZone != nil ? timeZone! : newCity.timeZone
      newCity.busy = busy != nil ? busy! : newCity.busy
      newCity.languageCode = languageCode != nil ? languageCode! : newCity.languageCode
      country?.addToCities(newCity)
    }
    
    do {
      try context.save()
    } catch {
      print("Failed saving")
    }
  }
  
  static func returnExistingCity(code : String) -> City?{
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "City")
    fetchRequest.predicate = NSPredicate(format: "code = %@", code)
    var results: [NSManagedObject] = []
    do {
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
      let context = appDelegate.persistentContainer.viewContext
      results = try context.fetch(fetchRequest)
    }
    catch {
      return nil
    }
    return results.first as? City
  }
  
  static func retrieveExistingCities() -> [City]{
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "City")
    let countrySort = NSSortDescriptor(key: "country.name", ascending: true)
    let citySort = NSSortDescriptor(key: "name", ascending: true)
    request.sortDescriptors = [countrySort,citySort]
    request.returnsObjectsAsFaults = false
    do {
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
      let context = appDelegate.persistentContainer.viewContext
      guard let result = try context.fetch(request) as? [City] else{ return [] }
      return result
    } catch {
      return []
    }
  }
  
}


