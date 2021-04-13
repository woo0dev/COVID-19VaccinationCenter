//
//  infoViewController.swift
//  COVID-19VaccinationCenter
//
//  Created by Woo0 on 2021/04/12.
//

import UIKit

class infoViewController: UIViewController {
    
    var address: String = ""
    
    @IBOutlet weak var titleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let centerData = try? JSONDecoder().decode(CenterData.self, from: jsonData!)
        
        var infoData: Datum = Datum(address: "", centerName: "", centerType: centerData!.data[0].centerType, facilityName: "", id: 0, lat: "", lng: "", org: "", sido: "", sigungu: "", zipCode: "")
        var infoText = ""

        for data in centerData!.data {
            if address == data.address {
                infoData = data
            }
        }
            
        infoText = "예방접종센터 주소 : \(infoData.address)"
            
        titleTextField.text = infoData.centerName
        infoTextView.text = infoText
        
    }
    
    @IBOutlet weak var infoTextView: UITextView!
}
