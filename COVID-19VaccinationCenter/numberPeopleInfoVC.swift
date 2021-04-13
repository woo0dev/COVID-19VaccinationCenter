//
//  numberPeopleInfoVC.swift
//  COVID-19VaccinationCenter
//
//  Created by Woo0 on 2021/04/13.
//

import UIKit

var numberPeopleURLString = "https://api.odcloud.kr/api/15077756/v1/vaccine-stat?page=1&perPage=10000&serviceKey=g4CVdFveh5eMEiCUuZtycJ2FiYeYVhwfFXURiUZ2Kex4vl4MemZRTtifCWHhwXy59GzlUQj9ICPvXYIgCkn7Dg%3D%3D"

let urlPeople = URL(string: numberPeopleURLString)

let jsonDataPeople = try! String(contentsOf: urlPeople!).data(using: .utf8)

struct CenterDataPeople: Codable {
    let currentCount: Int
    let data: [DatumPeople]
    let matchCount, page, perPage, totalCount: Int
}

struct DatumPeople: Codable {
    let accumulatedFirstCnt, accumulatedSecondCnt: Int
    let baseDate: String
    let firstCnt, secondCnt: Int
    let sido: String
    let totalFirstCnt, totalSecondCnt: Int
}


class numberPeopleInfoVC: UIViewController {
    
    var citySelect: String = ""

    @IBOutlet weak var numberPeopleTV: UITextView!
    
    @IBOutlet weak var titleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let centerDataPeople = try? JSONDecoder().decode(CenterDataPeople.self, from: jsonDataPeople!)
        
        var PeopleData: DatumPeople = DatumPeople(accumulatedFirstCnt: 0, accumulatedSecondCnt: 0, baseDate: centerDataPeople!.data[0].baseDate, firstCnt: 0, secondCnt: 0, sido: "", totalFirstCnt: 0, totalSecondCnt: 0)
        var PeopleText = ""
        
        for data in centerDataPeople!.data {
            if citySelect == data.sido {
                PeopleData = data
            }
        }
            
        PeopleText = "▶︎전체 누적 통계(1차 접종) :\n \(People(value: PeopleData.totalFirstCnt)) \n ▶︎전체 누적 통계(2차 접종) : \n \(People(value: PeopleData.totalSecondCnt)) \n ▶︎전일까지의 누적 통계(1차 접종) : \(People(value: PeopleData.accumulatedFirstCnt)) \n ▶︎전일까지의 누적 통계(2차 접종) :\n \(People(value: PeopleData.accumulatedSecondCnt)) \n ▶︎당일 통계(1차 접종) :\n \(People(value: PeopleData.firstCnt)) \n ▶︎당일 통계(2차 접종) :\n \(People(value: PeopleData.secondCnt)) \n ▶︎통계 기준일자 : \n \(PeopleData.baseDate) \n ▶︎지역 :\n \(PeopleData.sido) \n"
            
        titleTextField.text = PeopleData.sido + " 실시간 접종 현황"
        numberPeopleTV.text = PeopleText
        
    }
    
}

func People(value: Int) -> String{
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    let result = numberFormatter.string(from: NSNumber(value: value))! + "명"
    return result
}
