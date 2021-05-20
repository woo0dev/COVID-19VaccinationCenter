//
//  SideMenuNavigationVC.swift
//  COVID-19VaccinationCenter
//
//  Created by Woo0 on 2021/05/20.
//

import UIKit
import SideMenu

class SideMenuVC: UIViewController {
    
    let centerData = try? JSONDecoder().decode(CenterData.self, from: jsonData!)
    var address:String!
    var city = "전국"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        address =  centerData?.data[0].address
    }
    
    @IBAction func infoBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "infoSegue", sender: address)
    }
    
    @IBAction func peopleBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "peopleSegue", sender: city)
    }
    
    @IBAction func precautionBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "precautionSegue", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "infoSegue"{
            if let infoViewController = segue.destination as? infoViewController{ infoViewController.address = address } else { return }
        } else if segue.identifier == "peopleSegue"{
            if let numberPeopleInfoVC = segue.destination as? numberPeopleInfoVC{ numberPeopleInfoVC.citySelect = city } else { return }
        } else if segue.identifier == "precautionSegue"{
            if let precautionInfoVC = segue.destination as? precautionInfoVC{

            } else {return}
        }
    }
}

