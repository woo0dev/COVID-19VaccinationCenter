//
//  precautionInfoVC.swift
//  COVID-19VaccinationCenter
//
//  Created by Woo0 on 2021/04/13.
//

import UIKit

var images = ["vaccineImage.jpeg", "vaccineImage2.jpeg"]

class precautionInfoVC: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var textView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.numberOfPages = images.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.black
        imgView.image = UIImage(named: images[0])
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(precautionInfoVC.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(precautionInfoVC.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
        
//        let fontSize = UIFont.boldSystemFont(ofSize: 20)
//        let attributeText = NSMutableAttributedString(string: textView.text)
//        attributeText.addAttribute(.foregroundColor, value: UIColor(red: 124/255, green: 192/255, blue: 177/255, alpha: 1), range: (textView.text as NSString).range(of: "예방접종도우미 누리집 바로가기"))
//        attributeText.addAttribute(.font, value: fontSize, range: (textView.text as NSString).range(of: "예방접종도우미 누리집 바로가기"))
//
//        attributeText.addAttribute(.foregroundColor, value: UIColor(red: 82/255, green: 182/255, blue: 162/255, alpha: 1), range: (textView.text as NSString).range(of: "예방접종 후 건강상태 확인하기"))
//        attributeText.addAttribute(.font, value: fontSize, range: (textView.text as NSString).range(of: "예방접종 후 건강상태 확인하기"))
//
//        attributeText.addAttribute(.foregroundColor, value: UIColor.red, range: (textView.text as NSString).range(of: "예방접종 후 이상반응 신고하기"))
//        attributeText.addAttribute(.font, value: fontSize, range: (textView.text as NSString).range(of: "예방접종 후 이상반응 신고하기"))
//
//        textView.attributedText = attributeText
        
        textView.textAlignment = NSTextAlignment.center
        
        let linkedText = NSMutableAttributedString(attributedString: textView.attributedText)
        let helperLinked = linkedText.setAsLink(textToFind: "예방접종도우미 누리집 바로가기", linkURL: "https://nip.kdca.go.kr")
        let checkLinked = linkedText.setAsLink(textToFind: "예방접종 후 건강상태 확인하기", linkURL: "https://nip.kdca.go.kr/irgd/covid.do?MnLv1=3")
        let declarationLinked = linkedText.setAsLink(textToFind: "예방접종 후 이상반응 신고하기", linkURL: "https://nip.kdca.go.kr/irgd/index.html")
        
        if helperLinked || checkLinked || declarationLinked {
            textView.attributedText = NSAttributedString(attributedString: linkedText)
        }
                
        
        
        
    }
    
    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer{
            switch swipeGesture.direction {
                case UISwipeGestureRecognizer.Direction.left :
                    pageControl.currentPage += 1
                    imgView.image = UIImage(named: images[pageControl.currentPage])
                case UISwipeGestureRecognizer.Direction.right :
                    pageControl.currentPage -= 1
                    imgView.image = UIImage(named: images[pageControl.currentPage])
                default:
                    break
            }

        }

    }
    
    @IBAction func pageChanged(_ sender: UIPageControl) {
        imgView.image = UIImage(named: images[pageControl.currentPage])
    }
    
}

extension NSMutableAttributedString {

    public func setAsLink(textToFind:String, linkURL:String) -> Bool {
        
        // 하이퍼링크를 추가하고자 하는 text의 위치, 글자 수 를 찾는다.
        let foundRange = self.mutableString.range(of: textToFind)
        
        // text의 위치 존재 여부 확인
        if foundRange.location != NSNotFound {
           
           // 지정된 범위에 문자(링크)를 추가해준다.
           self.addAttribute(.link, value: linkURL, range: foundRange)
           
           // 위치가 맞다면 true 반환
           return true
        }
        
        // 위치가 틀리면 false 반환
        return false
    }
    
}
