//
//  ViewController.swift
//  UIAlertDemo
//
//  Created by apollo on 09/11/2016.
//  Copyright © 2016 projm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onAlert(_ sender: AnyObject) {
        let alert = UIAlertController(title: "HelloWorld", message: "你好，UIAlertController", preferredStyle: .alert)
        self.present(alert, animated: true) { 
            print("Show Alert!")
        }
        
    }

}

