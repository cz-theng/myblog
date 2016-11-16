//
//  ViewController.swift
//  UILabelDemo
//
//  Created by apollo on 15/11/2016.
//  Copyright © 2016 projm. All rights reserved.
//

import UIKit
import CoreText

class ViewController: UIViewController {

    func layoutLabel () {
        let lbl = UILabel()
        lbl.text = "I'm a sample label"

        
        
        //lbl.adjustsFontSizeToFitWidth = true
        //lbl.lineBreakMode = .byWordWrapping
        //lbl.allowsDefaultTighteningForTruncation = true

        lbl.baselineAdjustment = .alignBaselines

//        lbl.shadowColor = UIColor.red
//        lbl.shadowOffset = CGSize(width: 0, height: 5)
//        lbl.textRect(forBounds: lbl.frame, limitedToNumberOfLines: 0)
        
        lbl.backgroundColor = UIColor.yellow
        lbl.frame = CGRect(x: 10, y: 48, width: 200, height: 60)
        let txt = "I'm a attribute Text"
        let attrText = NSMutableAttributedString(string: txt )
        attrText.addAttribute(NSUnderlineStyleAttributeName, value: 2, range: NSRange(location: 0, length: txt.lengthOfBytes(using: .utf8)))
        lbl.attributedText = attrText
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

