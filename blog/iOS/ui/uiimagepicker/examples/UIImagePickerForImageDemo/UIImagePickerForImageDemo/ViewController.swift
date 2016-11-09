//
//  ViewController.swift
//  UIImagePickerForImageDemo
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
    
    func Confirm(title:String, message:String) {
        let alert = UIAlertController(title: title, message:message, preferredStyle: .alert);
        let confirm = UIAlertAction(title: "确定", style: .default, handler: { (UIAlertAction) in
            //
        })
        alert.addAction(confirm);
        self.present(alert, animated: true, completion: {
            print("\(title):\(message)")
        })

    }


    @IBAction func onTestBackendCamera(_ sender: AnyObject) {
        if (UIImagePickerController.isCameraDeviceAvailable(.rear)) {
            Confirm(title: "摄像头", message: "后置摄像头可用")
        } else {
            Confirm(title: "摄像头", message: "后置摄像头不可用")
        }
    }
    
    @IBAction func onTestFrontendCamera(_ sender: AnyObject) {
        if (UIImagePickerController.isCameraDeviceAvailable(.front)) {
            Confirm(title: "摄像头", message: "前置摄像头可用")
        } else {
            Confirm(title: "摄像头", message: "前置摄像头不可用")
        }
    }
}

