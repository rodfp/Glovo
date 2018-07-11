//
//  CitySelectorController.swift
//  Glovo
//
//  Created by Rodrigo Franco on 7/10/18.
//

import Foundation
import UIKit

class CitySelectorController : UIViewController{
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func close(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
}

extension CitySelectorController : UITableViewDelegate, UITableViewDataSource{
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return nil
  }
  
}
