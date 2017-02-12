//
//  ClubViewController.swift
//  handbalapp
//
//  Created by Marko Heijnen on 2/12/17.
//  Copyright © 2017 CodeKitchen B.V. All rights reserved.
//

import Foundation
import UIKit

class ClubViewController: UIViewController {
    var club:Club!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = club.name
    }
    
}
