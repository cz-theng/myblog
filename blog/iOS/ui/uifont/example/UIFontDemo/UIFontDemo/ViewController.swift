//
//  ViewController.swift
//  UIFontDemo
//
//  Created by apollo on 17/11/2016.
//  Copyright © 2016 projm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    func layoutUI() {
        let font = UIFont.systemFont(ofSize: 12.0)
        let pfont = UIFont.preferredFont(forTextStyle: .body)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.layoutUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

