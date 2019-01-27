//
//  JoinClassVC.swift
//  CUHackit2019
//
//  Created by John Garrett on 1/26/19.
//  Copyright © 2019 John Garrett. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import AWSRekognition
import FirebaseDatabase

class JoinClassVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
	
	@IBOutlet var cameraView: UIView!
	@IBOutlet var topBlock:   UIView!
	@IBOutlet var btmBlock:   UIView!
	@IBOutlet var lblTitle:   UILabel!
	@IBOutlet var btnVerify:  UIButton!
	@IBOutlet var btnScan:    UIButton!
	@IBOutlet var txtCode:    UITextField!
	
	private	var rekognitionObject:AWSRekognition?
	private var classCodes = [String]()
	private var ref:DatabaseReference?
	private var classID:String?

	override func viewDidLoad() {
		loadViewElements()
        super.viewDidLoad()
    }
	private func loadViewElements(){
		addImagePickerToContainerView()
		
		lblTitle.text      = "Scan class code"
		txtCode.isHidden   = true
		btnVerify.isHidden = true
		btnScan.isHidden   = false
		
		txtCode.layer.format()
		lblTitle.layer.format()
		btnVerify.layer.format()
		
		btnScan   .layer.format(withOpacity: 0.75)
		cameraView.layer.format(withOpacity: 0.75)
		
		topBlock.backgroundColor = UIColor.black.withAlphaComponent(0.5)
		btmBlock.backgroundColor = UIColor.black.withAlphaComponent(0.5)

		navigationController?.isNavigationBarHidden = true
	}
	
	@IBAction func verify(_ sender: Any) {
		if let code = txtCode.text{
			verifyText(code)
		}
	}
	@IBAction func rescanCode(_ sender: Any) {
		loadViewElements()
	}
	
	private func verifyText(_ code: String){
		if code != ""{
			ref = Database.database().reference().child("Classes").child(code)
			ref!.observe(.value) { (snapshot) in
				if snapshot.childrenCount == 0{
					self.alert("There is no class for this code.")
					self.allowManualEntry()
				}
				else{
					print("we are going to the class")
					self.classID = code
					self.performSegue(withIdentifier: "toUsernameVC", sender: self)
				}
			}
		}
		else{
			self.alert("Please input a code.")
			self.allowManualEntry()
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "toUsernameVC"{
			if let destination = segue.destination as? InputUsernameVC, let code = classID{
				ref?.removeAllObservers()
				destination.classID = code
			}
		}
	}
	
	// MARK: - Image Stuff
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		dismiss(animated: true)
		
		guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
			self.alert("Error loading image, please manually input the class code.")
			allowManualEntry()
			return
		}
		
		let textImage:Data = image.jpegData(compressionQuality: 0.5)!
		
		detectText(fromImageData: textImage)
	}
	
	private func presentOptions(){
		DispatchQueue.main.async {
			let vc = UIViewController()
			
			vc.preferredContentSize = CGSize(width: 250,height: 300)
			let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 300))
			pickerView.delegate   = self
			pickerView.dataSource = self
			
			vc.view.addSubview(pickerView)
			
			if self.classCodes.count == 0{
					self.alert("No class codes detected from camera. Please enter manually")
				self.allowManualEntry()
			}
			let editRadiusAlert = UIAlertController(title: "Choose correct class code",
													message: "",
													preferredStyle: UIAlertController.Style.alert)
			
			editRadiusAlert.setValue(vc, forKey: "contentViewController")
			editRadiusAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
				self.classID = self.classCodes[pickerView.selectedRow(inComponent: 0)]
				self.verifyText(self.classID ?? "")
			}))
			editRadiusAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
				self.allowManualEntry()
			}))
			
			self.present(editRadiusAlert, animated: true)
		}
	}
	
	private func allowManualEntry(){
		DispatchQueue.main.async {
			  self.txtCode.isHidden = false
			self.btnVerify.isHidden = false
			self.lblTitle.text = "Enter class code"
			self.cameraView.removeFromSuperview()
		}
	}
	
	//MARK: - AWS Methods
	func detectText(fromImageData: Data){
		lblTitle.text = "Loading class code..."
		
		rekognitionObject   = AWSRekognition.default()
		let request         = AWSRekognitionDetectTextRequest.init()
		let codeImageAWS    = AWSRekognitionImage()
		codeImageAWS?.bytes = fromImageData
		request?.image      = codeImageAWS
		
		rekognitionObject?.detectText(request!, completionHandler: { (result, error) in
			if error != nil{
				self.alert((error?.localizedDescription)!)
				return
			}
			
			if (result?.textDetections?.count)! > 0{
				for textResult in (result?.textDetections)!{
					if (textResult.confidence?.intValue)! > 90{
						if !self.classCodes.contains(textResult.detectedText!){
							self.classCodes.append(textResult.detectedText ?? "")
						}
					}
				}
				self.presentOptions()
			}
			else{
				self.alert("No code detected, please manually enter a code.")
				self.allowManualEntry()
			}
		})
	}
	
	var imagePickers:UIImagePickerController?
	
	func addImagePickerToContainerView(){
		
		imagePickers = UIImagePickerController()
		if UIImagePickerController.isCameraDeviceAvailable( UIImagePickerController.CameraDevice.rear) {
			imagePickers?.delegate   = self
			imagePickers?.sourceType = UIImagePickerController.SourceType.camera
			
			addChild(imagePickers!)
			self.cameraView.addSubview((imagePickers?.view)!)
			self.cameraView.addSubview(topBlock)
			self.cameraView.addSubview(btmBlock)
			
			imagePickers?.view.frame               = cameraView.bounds
			imagePickers?.view.layer.cornerRadius  = 6
			imagePickers?.view.layer.masksToBounds = true
			imagePickers?.allowsEditing            = false
			imagePickers?.showsCameraControls      = false
			
			imagePickers?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		}
		else{
			allowManualEntry()
		}
	}

	@IBAction func scanFromEmbededView(_ sender: Any) {
		if UIImagePickerController.isSourceTypeAvailable(.camera){
			imagePickers?.takePicture()
			btnScan.isHidden = true
		}
		else{
			self.alert("Camera input is unavaliable, please input your class code manually.")
			allowManualEntry()
		}
	}
	//MARK: Picker View Methods
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return classCodes.count
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return classCodes[row]
	}
}

extension CALayer{
	func format(withOpacity opacity: Float = 0.5){
		self.masksToBounds = false
		self.shadowOpacity = opacity
		self.shadowRadius  = 8
		self.cornerRadius  = 6.0
		self.shadowColor   = UIColor.gray.cgColor
		self.shadowOffset  = CGSize(width: 2.0, height: 2.0)
	}
}
