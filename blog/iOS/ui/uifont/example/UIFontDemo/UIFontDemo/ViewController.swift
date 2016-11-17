//
//  ViewController.swift
//  UIFontDemo
//
//  Created by apollo on 17/11/2016.
//  Copyright © 2016 projm. All rights reserved.
//

import UIKit
import CoreText
import Foundation
import CoreTelephony

class ViewController: UIViewController {

    func layoutUI() {
        let font = UIFont.systemFont(ofSize: 12.0)
        let pfont = UIFont.preferredFont(forTextStyle: .body)
        
        let family = UIFont.familyNames
        for fam in family {
            let fonts = UIFont.fontNames(forFamilyName: fam)
            print("Font Family: \(fam)")
            for f in fonts {
                print("\t\t Font:\(f)")
            }
        }
        
        let monacoFont = UIFont(name: "Monaco", size: UIFont.systemFontSize)
        print("monacoFont is \(monacoFont)")
        let fontURL = Bundle.main.path(forResource: "MONACO", ofType: "ttf")
        let fontData = NSData(contentsOfFile: fontURL!)
        let providerRef = CGDataProvider(data: fontData!)
        let fontRef = CGFont(providerRef!)
        var error: Unmanaged<CFError>?
        if CTFontManagerRegisterGraphicsFont(fontRef, &error) {
            let mFont = UIFont(name: "Monaco", size: UIFont.systemFontSize)
            print("mFont is \(mFont)")
        }
        

        let fontPSName = "STBaoliSC-Regular"
        
        var attr : [String:String] = [kCTFontNameAttribute as String : fontPSName]
        let desc = CTFontDescriptorCreateWithAttributes(attr as CFDictionary)
        var descs : [CTFontDescriptor] = [desc,]
        CTFontDescriptorMatchFontDescriptorsWithProgressHandler(descs as CFArray, nil) { (stat, prama) -> Bool in
            //
            if .didFinish == stat {
                let nishuFont = UIFont(name: fontPSName, size: UIFont.systemFontSize)
                print("nishuFont is \(nishuFont)")
            }
            return true
        }
        
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

