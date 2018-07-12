//
//  CountryDataHandler.swift
//  Glovo
//
//  Created by Rodrigo Franco on 7/10/18.
//

import Foundation
import UIKit
import CoreData
import SwiftyJSON

class CountryDataHandler : NSObject {
  
  static func saveCountry(_ json : JSON){
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let context = appDelegate.persistentContainer.viewContext
    guard let code = json["code"].string else{ return }
    guard let name = json["name"].string else{ return }
    guard let country = NSEntityDescription.entity(forEntityName: "Country", in: context) else { return }
    if let existingCountry = returnExistingCountry(code: code) {
      existingCountry.code = code
      existingCountry.name = name
    }else{
      guard let newCountry = NSManagedObject(entity: country, insertInto: context) as? Country else { return }
      newCountry.code = code
      newCountry.name = name
    }
    do {
      try context.save()
    } catch {
      print("Failed saving")
    }
  }
  
  static func returnExistingCountry(code : String) -> Country?{
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Country")
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
    return results.first as? Country
  }
  
  static func retrieveExistingCountries(withOrderedCities : Bool? = false) -> [Country]{
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Country")
    request.returnsObjectsAsFaults = false
    let sort = NSSortDescriptor(key: "name", ascending: true)
    request.sortDescriptors = [sort]
    do {
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
      let context = appDelegate.persistentContainer.viewContext
      guard let result = try context.fetch(request) as? [Country] else{ return [] }
      return result
    } catch {
      return []
    }
  }
  
}
