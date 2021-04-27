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
        
        let index: String.Index = centerDataPeople!.data[0].baseDate.index(centerDataPeople!.data[0].baseDate.startIndex, offsetBy: 9)
        let indexStart: String.Index = centerDataPeople!.data[0].baseDate.index(centerDataPeople!.data[0].baseDate.startIndex, offsetBy: 5)
        
        barChartView.noDataText = "데이터가 없습니다."
        barChartView.noDataFont = .systemFont(ofSize: 20)
        barChartView.noDataTextColor = .lightGray
        
        numberPeopleTV.textColor = .black
        
        
        for data in centerDataPeople!.data {
            if citySelect == data.sido {
                PeopleData = data
                sido.append(data.sido)
                cnt.append(Double(data.totalFirstCnt))
                date.append(String(data.baseDate[indexStart...index]))
            }
        }
        
        setChart(dataPoints: sido, values: cnt, date: date)
            
        let totalFirstIncrease = PeopleData.totalFirstCnt-PeopleData.accumulatedFirstCnt
        let totalSecondIncrease = PeopleData.totalSecondCnt-PeopleData.accumulatedSecondCnt
        
        PeopleText = "▶︎전체 누적 통계(1차 접종) \n \(People(value: PeopleData.totalFirstCnt)) ▴\(totalFirstIncrease) \n\n ▶︎전체 누적 통계(2차 접종) \n \(People(value: PeopleData.totalSecondCnt)) ▴\(totalSecondIncrease) \n\n ▶︎당일 통계(1차 접종) \n \(People(value: PeopleData.firstCnt)) \n\n ▶︎당일 통계(2차 접종) \n \(People(value: PeopleData.secondCnt)) \n\n \(PeopleData.baseDate[...index]) \n"
            
        titleTextField.text = PeopleData.sido + " 실시간 접종 현황"
        numberPeopleTV.text = PeopleText

        let titleSize = UIFont.boldSystemFont(ofSize: 27)
        let fontSize = UIFont.boldSystemFont(ofSize: 20)
        let attributeText = NSMutableAttributedString(string: numberPeopleTV.text)

        attributeText.addAttribute(.foregroundColor, value: UIColor.blue, range: (numberPeopleTV.text as NSString).range(of: "▴" + String(totalFirstIncrease)))
        attributeText.addAttribute(.foregroundColor, value: UIColor.blue, range: (numberPeopleTV.text as NSString).range(of: "▴" + String(totalSecondIncrease)))
        
        attributeText.addAttribute(.font, value: fontSize, range: (numberPeopleTV.text as NSString).range(of: "\(People(value: PeopleData.totalFirstCnt)) ▴\(totalFirstIncrease)"))
        attributeText.addAttribute(.font, value: fontSize, range: (numberPeopleTV.text as NSString).range(of: "\(People(value: PeopleData.totalSecondCnt)) ▴\(totalSecondIncrease)"))
        attributeText.addAttribute(.font, value: fontSize, range: (numberPeopleTV.text as NSString).range(of: "\(People(value: PeopleData.firstCnt))"))
        attributeText.addAttribute(.font, value: fontSize, range: (numberPeopleTV.text as NSString).range(of: "\(People(value: PeopleData.secondCnt))"))
        
        attributeText.addAttribute(.font, value: titleSize, range: (numberPeopleTV.text as NSString).range(of: "▶︎전체 누적 통계(1차 접종)"))
        attributeText.addAttribute(.font, value: titleSize, range: (numberPeopleTV.text as NSString).range(of: "▶︎전체 누적 통계(2차 접종)"))
        attributeText.addAttribute(.font, value: titleSize, range: (numberPeopleTV.text as NSString).range(of: "▶︎당일 통계(1차 접종)"))
        attributeText.addAttribute(.font, value: titleSize, range: (numberPeopleTV.text as NSString).range(of: "▶︎당일 통계(2차 접종)"))
        
        
        numberPeopleTV.attributedText = attributeText
        
    }
    
    func setChart(dataPoints: [String], values: [Double], date: [String]) {
        var dataEntries: [BarChartDataEntry] = []
        for i in dataPoints.endIndex-7...dataPoints.endIndex-1 {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        // 차트가 어떤 데이터인지 보여준다.
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "접종인원")
        // 라벨의 위치
        barChartView.xAxis.labelPosition = .bottom
        // x축 데이터 라벨
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: date)
        // x축 데이터 간격
        barChartView.xAxis.granularity = 1
        // 차트 우측에 y축 데이터 수치 표시 여부 false
        barChartView.rightAxis.enabled = false
        // 차트 애니메이션
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

