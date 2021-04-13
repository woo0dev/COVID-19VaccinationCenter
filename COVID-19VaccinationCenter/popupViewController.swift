//
//  popupViewController.swift
//  COVID-19VaccinationCenter
//
//  Created by Woo0 on 2021/04/12.
//

import UIKit

class popupViewController: UIViewController {
    
    var img: UIImage?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var acceptBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        img = UIImage(named: "예방접종2분기.jpeg")
        imageView.image = img
        
        acceptBtn.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissView(){
        dismiss(animated: false, completion: nil)
    }

}
