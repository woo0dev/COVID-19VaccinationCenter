//
//  launchScreenVC.swift
//  COVID-19VaccinationCenter
//
//  Created by Woo0 on 2021/04/13.
//

import UIKit

class launchScreenVC: UIViewController {
    
    var img: UIImage?
    
    @IBOutlet weak var launchImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        img = UIImage(named: "예방접종2분기.jpeg")
        launchImage.image = img
    }

}
