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
    let takeBtn = UIButton(type: .system)
    let flashBtn = UIButton(type: .system)
    let cameraBtn = UIButton(type: .system)
    let cameraView = UIView()
    
    var cameraMode : UIImagePickerControllerCameraDevice = .rear
    var flashMode : UIImagePickerControllerCameraFlashMode = .auto
    
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
            picker.cameraDevice = .rear
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
    
    @IBAction func onTakePhoto () {
        picker.takePicture()
    }
    
    @IBAction func onSwitchCamera() {
        if cameraMode == .rear {
            picker.cameraDevice = .front
            cameraBtn.setTitle("Rear", for: .normal)
            cameraMode = .front
        } else {
            picker.cameraDevice = .rear
            cameraBtn.setTitle("Front", for: .normal)
            cameraMode = .rear
        }
    }
    
    @IBAction func onFlashMode () {
        if flashMode == .auto || flashMode == .on {
            picker.cameraFlashMode = .off
            flashMode = .off
            flashBtn.setTitle("FlashON", for: .normal)
        } else {
            picker.cameraFlashMode = .on
            flashMode = .on
            flashBtn.setTitle("FlashOFF", for: .normal)
        }
    }
    
    /** UINavigationControllerDelegate **/
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        cameraView.frame = CGRect(x: 0, y: self.view.bounds.size.height-100, width: self.view.bounds.size.width, height: 100)
        cameraView.backgroundColor = UIColor.blue
        //cameraView.alpha = 0.5

        
        
        takeBtn.frame = CGRect(x: 140, y: 30, width: 100, height: 40)
        takeBtn.backgroundColor = UIColor.green
        takeBtn.layer.cornerRadius = 10
        takeBtn.setTitle("TakePhoto", for: .normal)
        takeBtn.addTarget(self, action: #selector(onTakePhoto), for: .touchDown)
        cameraView.addSubview(takeBtn)
        flashBtn.frame = CGRect(x: 20, y: 30, width: 100, height: 40)
        flashBtn.addTarget(self, action: #selector(onFlashMode), for: .touchDown)
        flashBtn.backgroundColor = UIColor.green
        flashBtn.layer.cornerRadius = 10.0
        flashBtn.setTitle("FlashOFF", for: .normal)
        cameraView.addSubview(flashBtn)
        cameraBtn.frame = CGRect(x: 260, y: 30, width: 100, height: 40)
        cameraBtn.backgroundColor = UIColor.green
        cameraBtn.layer.cornerRadius = 10
        cameraBtn.addTarget(self, action: #selector(onSwitchCamera), for: .touchDown)
        cameraBtn.setTitle("Front", for: .normal)
        cameraView.addSubview(cameraBtn)

        cameraMode = .rear
        flashMode = .auto
        picker.cameraOverlayView = cameraView
        
    }
}

