//
//  numberPeopleInfoVC.swift
//  COVID-19VaccinationCenter
//
//  Created by Woo0 on 2021/04/13.
//

import UIKit
import Charts

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
    var sido: [String] = []
    var cnt: [Double] = []
    var date: [String] = []

    @IBOutlet weak var numberPeopleTV: UITextView!
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var barChartView: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let centerDataPeople = try? JSONDecoder().decode(CenterDataPeople.self, from: jsonDataPeople!)
        
        var PeopleData: DatumPeople = DatumPeople(accumulatedFirstCnt: 0, accumulatedSecondCnt: 0, baseDate: centerDataPeople!.data[0].baseDate, firstCnt: 0, secondCnt: 0, sido: "", totalFirstCnt: 0, totalSecondCnt: 0)
        var PeopleText = ""
        
        var indexY: String.Index = centerDataPeople!.data[0].baseDate.index(centerDataPeople!.data[0].baseDate.startIndex, offsetBy: 9)
        var indexMStart: String.Index = centerDataPeople!.data[0].baseDate.index(centerDataPeople!.data[0].baseDate.startIndex, offsetBy: 5)
        var indexM: String.Index = centerDataPeople!.data[0].baseDate.index(indexMStart, offsetBy: 9)
        
        barChartView.noDataText = "데이터가 없습니다."
        barChartView.noDataFont = .systemFont(ofSize: 20)
        barChartView.noDataTextColor = .lightGray
        
        numberPeopleTV.textColor = .black
        
        
        for data in centerDataPeople!.data {
            if citySelect == data.sido {
                PeopleData = data
                sido.append(data.sido)
                cnt.append(Double(data.totalFirstCnt))
                date.append(String(data.baseDate[indexMStart...indexY]))
//                if citySelect != "전국" {
//                    cnt.append(Double(data.totalSecondCnt))
//                    cnt.append(Double(data.accumulatedFirstCnt))
//                    cnt.append(Double(data.accumulatedSecondCnt))
//                    cnt.append(Double(data.firstCnt))
//                    cnt.append(Double(data.secondCnt))
//                }
            }
        }
        
        setChart(dataPoints: sido, values: cnt, date: date)
            
        var totalFirstIncrease = PeopleData.totalFirstCnt-PeopleData.accumulatedFirstCnt
        var totalSecondIncrease = PeopleData.totalSecondCnt-PeopleData.accumulatedSecondCnt
        
        
        PeopleText = "▶︎전체 누적 통계(1차 접종) :\n \(People(value: PeopleData.totalFirstCnt)) ▴\(totalFirstIncrease) \n ▶︎전체 누적 통계(2차 접종) : \n \(People(value: PeopleData.totalSecondCnt)) ▴\(totalSecondIncrease) \n ▶︎당일 통계(1차 접종) :\n \(People(value: PeopleData.firstCnt)) \n ▶︎당일 통계(2차 접종) :\n \(People(value: PeopleData.secondCnt)) \n \(PeopleData.baseDate[...indexY]) \n"
            
        titleTextField.text = PeopleData.sido + " 실시간 접종 현황"
        numberPeopleTV.text = PeopleText

        let attributeText = NSMutableAttributedString(string: numberPeopleTV.text)
        
        //attributeText.addAttribute(.foregroundColor, value: UIColor.white, range: numberPeopleTV.text)
        attributeText.addAttribute(.foregroundColor, value: UIColor.blue, range: (numberPeopleTV.text as NSString).range(of: "▴" + String(totalFirstIncrease)))
        attributeText.addAttribute(.foregroundColor, value: UIColor.blue, range: (PeopleText as NSString).range(of: "▴" + String(totalSecondIncrease)))
        
        numberPeopleTV.attributedText = attributeText
        
    }
    
    func setChart(dataPoints: [String], values: [Double], date: [String]) {
        var dataEntries: [BarChartDataEntry] = []
        for i in dataPoints.endIndex-7...dataPoints.endIndex-1 {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }

        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "접종인원")
        
        
        
        barChartView.xAxis.labelPosition = .bottom
        
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: date)
        
        barChartView.xAxis.granularity = 1
        
        //barChartView.xAxis.setLabelCount(dataPoints.count, force: false)

        barChartView.rightAxis.enabled = false
        
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        // 차트 컬러
        chartDataSet.colors = [.systemBlue]
        
        // 데이터 삽입
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
    }

    
}

func People(value: Int) -> String{
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    let result = numberFormatter.string(from: NSNumber(value: value))! + "명"
    return result
}

