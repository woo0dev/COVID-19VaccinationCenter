//
//  infoViewController.swift
//  COVID-19VaccinationCenter
//
//  Created by Woo0 on 2021/04/12.
//

import UIKit

struct Welcome2 {
    let response: Response
}

struct Response {
    let header: Header
    let body: Body
}

struct Body {
    let items: Items
    let numOfRows, pageNo, totalCount: String
}

struct Items {
    let item: Item
}

struct Item {
    let accDefRate, accExamCnt, accExamCompCnt, careCnt: String
    let clearCnt, createDt, deathCnt, decideCnt: String
    let examCnt, resutlNegCnt, seq, stateDt: String
    let stateTime, updateDt: String
}

struct Header {
    let resultCode, resultMsg: String
}

class infoViewController: UIViewController, XMLParserDelegate    {
    
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
    
    func setParser(from url: URL, delegate: XMLParserDelegate) {
        let parser = XMLParser(contentsOf: url)
        parser!.delegate = self
        parser!.parse()
    }
}
