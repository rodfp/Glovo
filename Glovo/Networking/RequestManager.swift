//
//  RequestManager.swift
//  Glovo
//
//  Created by Rodrigo Franco on 7/10/18.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire

typealias RequestCompletionHandler = (_ success: Bool, _ statusCode: Int?, _ dataJSON: JSON?, _ erorJSON: JSON?) -> Void

class RequestManager : NSObject {
  
  static let shared = RequestManager()
  
  override init() {
    super.init()
  }
  
  //URLs used in the application.
  
  private var apiURL: URL {
    return URL(string: "http://localhost:3000/api")!
  }
  
  private var countriesURL : URL {
    return apiURL.appendingPathComponent("countries")
  }
  
  private var citiesURL : URL {
    return apiURL.appendingPathComponent("cities")
  }
  
  func citiesDetailsURL(cityCode : String) -> URL {
    return apiURL.appendingPathComponent("cities/\(cityCode)")
  }
  
  //Individual requests.
  
  func getAllCountries(completion : @escaping (Bool) -> Void){
    apiRequest(method: .get, url: countriesURL) { (success, statusCode, data, error) in
      if success{
        guard let countries = data?.array else { completion(false); return }
        for country in countries {
          CountryDataHandler.saveCountry(country)
        }
        completion(true)
      }else{
        completion(false)
      }
    }
  }
  
  func getAllCities(completion : @escaping (Bool) -> Void){
    apiRequest(method: .get, url: citiesURL) { (success, statusCode, data, error) in
      if success{
        guard let cities = data?.array else { completion(false); return }
        for city in cities {
          CityDataHandler.saveCity(city)
        }
        completion(true)
      }else{
        completion(false)
      }
    }
  }
  
  func getCityDetails(_ cityCode : String, completion : @escaping (Bool) -> Void){
    let url = citiesDetailsURL(cityCode: cityCode)
    apiRequest(method: .get, url: url) { (success, statusCode, data, error) in
      if success{
        guard let cities = data else { completion(false); return }
        print(cities.dictionaryValue)
        completion(true)
      }else{
        completion(false)
      }
    }
  }
  
  
  //This will handle all requests added.
  
  func apiRequest(method: HTTPMethod, url: URL, parameters: Parameters? = nil, headers: HTTPHeaders? = nil, responseQueue: DispatchQueue? = nil, completion: @escaping RequestCompletionHandler) {
    Alamofire.request(url,
                      method: method,
                      parameters: parameters,
                      encoding: JSONEncoding.default,
                      headers: headers).responseJSON { [weak self] (response) in
                        self?.parseJSONResponse(response: response, requestMethod: method, requestURL: url, completion: completion)
    }
    
  }
  
  //Parsing the JSONs returned by the server.
  
  func parseJSONResponse(response: DataResponse<Any>, requestMethod method: HTTPMethod, requestURL url: URL, completion: @escaping RequestCompletionHandler, requestParameters: Parameters? = nil) {
    
    let statusCode = response.response?.statusCode ?? -2
    var dataJSON: JSON?
    if let data = response.result.value {
      dataJSON = JSON(data)
    }
    
    guard response.result.isSuccess else {
      let error = response.result.error?.localizedDescription ?? "Could not parse error"
      completion(false, statusCode, nil, ["message": error])
      return
    }
    
    guard dataJSON != nil else {
      completion(false, statusCode, nil, ["message": "Could not cast response JSON."])
      return
    }
    
    if 200..<300 ~= response.response!.statusCode {
      completion(true, statusCode, dataJSON, nil)
    } else {
      completion(false, statusCode, nil, dataJSON)
    }
    
  }
  
}
