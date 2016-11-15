//
//  ViewController.swift
//  UILabelDemo
//
//  Created by apollo on 15/11/2016.
//  Copyright © 2016 projm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    func layoutLabel () {
        let lbl = UILabel()
        lbl.text = "I'm a sample label"
        lbl.adjustsFontSizeToFitWidth = true
        //lbl.lineBreakMode = .byWordWrapping
        //lbl.allowsDefaultTighteningForTruncation = true
        lbl.frame = CGRect(x: 10, y: 48, width: 200, height: 60)
        lbl.baselineAdjustment = .alignBaselines
        lbl.backgroundColor = UIColor.yellow
        lbl.shadowColor = UIColor.red
        lbl.shadowOffset = CGSize(width: 0, height: 5)
        lbl.textRect(forBounds: lbl.frame, limitedToNumberOfLines: 0)
        self.view.addSubview(lbl)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.layoutLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

