//
//  ViewController.swift
//  UIImagePickerForImageDemo
//
//  Created by apollo on 09/11/2016.
//  Copyright © 2016 projm. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let picker = UIImagePickerController()
    
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

    @IBAction func onWhichCamera(_ sender: AnyObject) {
        if UIImagePickerController.isCameraDeviceAvailable(.rear) {
            Confirm(title: "摄像头", message: "后置摄像头可用")
            picker.cameraDevice = .front
        } else if UIImagePickerController.isCameraDeviceAvailable(.front) {
            Confirm(title: "摄像头", message: "后置摄像头不可用，但前置摄像头可用")
            picker.cameraDevice = .front
        } else {
            Confirm(title: "摄像头", message: "后置摄像头不可用，前置摄像头也可用")
        }
    }
    
    
    @IBAction func onMediaSource(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            Confirm(title: "SourceType", message: "设置为.camera SourceType")
        }
    }

    @IBAction func onSetMediaType(_ sender: AnyObject) {
        let types = UIImagePickerController.availableMediaTypes(for: .camera)
        if let ts = types {
            if ts.contains(kUTTypeImage as String) {
                picker.mediaTypes = [kUTTypeImage as String]
                Confirm(title: "kUTTypeImage", message: "设置为采集照片模式")
            }
        }
    }

    @IBAction func onTakePhotos(_ sender: AnyObject) {
        picker.allowsEditing = true
        picker.showsCameraControls = false
        picker.cameraFlashMode = .auto
        picker.delegate = self
        
        self.present(picker, animated: true) {
            //
        }
    }
    
    
    func onSave(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            Confirm(title: "Save Failed", message: error.localizedDescription)
        } else {
            Confirm(title: "Save Succfull", message: "Your altered image has been saved to your photos.")
        }
    }
    
    /** UIImagePickerControllerDelegate  **/
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //
        let img = info[UIImagePickerControllerOriginalImage]
        UIImageWriteToSavedPhotosAlbum(img as! UIImage, self, #selector(onSave(_:didFinishSavingWithError:contextInfo:)), nil)
        
        picker.dismiss(animated: true) { 
            //
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //
        picker.dismiss(animated: true) {
            //
        }
    }
    
    
    /** UINavigationControllerDelegate **/
}

