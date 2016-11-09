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
    
    @IBAction func onPopAlertView(_ sender: AnyObject) {
        let alert = UIAlertController(title: "AlertView", message: "点击确认，去除提示！", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "确认", style: .default) { (UIAlertAction) in
            //
            print("Click Confirm")
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel) { (UIAlertAction) in
            //
            print("Click Cancel")
        }
        let destructive = UIAlertAction(title: "删除", style: .destructive) { (UIAlertAction) in
            //
            print("Click Destructive")
        }
        
        
        alert.addAction(confirm);
        alert.addAction(destructive);
        alert.addAction(cancel);
        
        self.present(alert, animated: true) {
            print("Show Alert!")
        }
    }

    @IBAction func onPopActionSheet(_ sender: AnyObject) {
        let alert = UIAlertController(title: "ActionSheet", message: "点击确认，去除底部提示！", preferredStyle: .actionSheet)
        let confirm = UIAlertAction(title: "确认", style: .default) { (UIAlertAction) in
            //
            print("Click Confirm")
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel) { (UIAlertAction) in
            //
            print("Click Cancel")
        }
        let destructive = UIAlertAction(title: "删除", style: .destructive) { (UIAlertAction) in
            //
            print("Click Destructive")
        }
        
        //alert.addAction(confirm);
        alert.addAction(cancel);
        //alert.addAction(destructive);
        
        self.present(alert, animated: true) {
            print("Show Alert!")
        }

    }

    @IBAction func onPopMoreAlert(_ sender: AnyObject) {
        let alert = UIAlertController(title: "MoreAlertView", message: "请输入姓名", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "确认", style: .default) { (UIAlertAction) in
            //
            print("Click Confirm")
            if let txt = alert.textFields?[0] {
                print("Name is ", txt.text)
            }
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel) { (UIAlertAction) in
            //
            print("Click Cancel")
        }
        
        alert.addTextField { (txt) in
            txt.placeholder = "姓名"
        }
        
        
        //confirm.isEnabled = false;
        alert.addAction(confirm);
        alert.addAction(cancel);
        
        self.present(alert, animated: true) {
            print("Show Alert!")
        }

    }
}

