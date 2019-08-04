//
//  ViewController.swift
//  __PRODUCT_NAME__Example
//
//  Created by Paul Calnan on 8/4/19.
//  Copyright © 2019 __ORGANIZATION_NAME__. All rights reserved.
//

import __PRODUCT_NAME__
import UIKit

class ViewController: UIViewController {

    @IBOutlet var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = __PRODUCT_NAME__.text
    }
}

