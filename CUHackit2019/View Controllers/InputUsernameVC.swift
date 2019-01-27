//
//  InputUsernameVC.swift
//  CUHackit2019
//
//  Created by John Garrett on 1/26/19.
//  Copyright © 2019 John Garrett. All rights reserved.
//

import UIKit
import FirebaseDatabase
class InputUsernameVC: UIViewController {
	@IBOutlet var lblClassname: UILabel!
	@IBOutlet var btnNext:      UIButton!
	@IBOutlet var txtUsername:  UITextField!
	
	public  var classID:String?
	private var  phrase:String?
	private var occurances:Int?
	private var classMembers = [String]()
	
	lazy private var classRef = Database.database().reference().child("Classes").child(classID!)
	
    override func viewDidLoad() {
		loadValues()
		super.viewDidLoad()
		
		lblClassname.layer.format()
		 txtUsername.layer.format()
		 	 btnNext.layer.format()
		
		btnNext.isHidden = true
    }
	
	override func viewDidDisappear(_ animated: Bool) {
		classRef.removeAllObservers()
	}
	
	@IBAction func editingBegan(_ sender: Any) {
		btnNext.isHidden = false
	}
	
	private func loadValues(){
		if classID == nil{
			self.alert("error getting class id")
			return
		}
		
		//get class name
		classRef.observe(.value) { (snapshot) in
			if let dict = snapshot.value as? [String:Any]{
				self.lblClassname.text = "Welcome to \(dict["className"] ?? "null")"
			}
		}
		classRef.child("Phrase").observe(.value) { (snapshot) in
			if snapshot.childrenCount == 0{
				self.alert("Your professor hasn't set up any phrases.")
			}
			for phrase in snapshot.children.allObjects as! [DataSnapshot] {
				self.phrase = phrase.key
				self.occurances = phrase.value as? Int
			}
		}
		
		//get class members
		classRef.child("Members").observe(.value) { (snapshot) in
			for usrName in snapshot.children.allObjects as! [DataSnapshot] {
				self.classMembers.append(usrName.key)
			}
		}
	}
	
	private func addMember(_ member:String){
		classRef.child("Members").child(member).updateChildValues(["id":member, "score":0])
	}
	
	@IBAction func next(_ sender: Any) {
		let username = txtUsername.text
		
		if username != nil && username != ""{
			if !classMembers.contains(username!){
				addMember(username!)
				performSegue(withIdentifier: "toMainVC", sender: self)
			}
			else{
				self.alert("This username is already taken, please select another.")
				btnNext.isHidden = true
			}
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "toMainVC", let destination = segue.destination as? MainVC{
			destination.phrase     = self.phrase
			destination.classID    = self.classID
			destination.occurances = self.occurances
			destination.username   = self.txtUsername.text
		}
	}
	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		if identifier == "toMainVC"{
			if self.classID != nil && self.phrase != nil && self.occurances != nil && self.txtUsername.text != nil{
				return true
			}
			self.alert("We are missing data, you are unable to join the class.")
			return false
		}
		return false
	}
}

extension UIViewController{
	func alert(_ text: String){
		let alert = UIAlertController(title: "Alert", message: text, preferredStyle: UIAlertController.Style.alert)
		alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
}
