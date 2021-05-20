//
//  CustomSideMenu.swift
//  COVID-19VaccinationCenter
//
//  Created by Woo0 on 2021/05/20.
//

import UIKit
import SideMenu

class CustomSideMenu: SideMenuNavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presentationStyle = .menuSlideIn
        self.leftSide = true
        self.statusBarEndAlpha = 0.0
        self.menuWidth = self.view.frame.width * 1.0
        
    }
}
