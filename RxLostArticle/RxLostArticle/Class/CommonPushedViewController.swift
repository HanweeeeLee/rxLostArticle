//
//  CommonPushedViewController.swift
//  RxLostArticle
//
//  Created by hanwe lee on 2020/09/25.
//

import UIKit
import SwipeTransition

class CommonPushedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.swipeBack?.isEnabled = true
    }

}
