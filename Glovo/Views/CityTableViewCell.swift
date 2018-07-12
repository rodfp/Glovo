//
//  CityTableViewCell.swift
//  Glovo
//
//  Created by Rodrigo Franco on 7/11/18.
//

import Foundation
import UIKit

class CityTableViewCell : UITableViewCell{
  
  @IBOutlet weak var nameLabel: UILabel!
  
  func setupCell(_ city : City){
    self.nameLabel.text = city.name
  }
  
}
