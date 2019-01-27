//
//  MainVC.swift
//  CUHackit2019
//
//  Created by John Garrett on 1/26/19.
//  Copyright © 2019 John Garrett. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MainVC: UIViewController {
	var phrase:   String?
	var classID:  String?
	var username: String?
	var occurances:  Int?
	
	var ref:DatabaseReference?
	
	@IBOutlet var lblPhrase:    UILabel!
	@IBOutlet var lblCurrScore: UILabel!
	@IBOutlet var btnScore: UIButton!
	
	@IBOutlet var btnEnd: UIButton!
	private var score = 0{
		didSet{
			guard isViewLoaded else { return }
			lblCurrScore.text = "current score: \(score)"
			ref?.updateChildValues(["score": score])
		}
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		ref = Database.database().reference().child("Classes").child(classID!).child("Members").child(username!)
		lblPhrase.text = phrase
		
		lblPhrase.layer.format()
		btnScore.layer.format()
		btnEnd.layer.format()
	}
	
	@IBAction func pressButton(_ sender: UIButton) {
		score += 1
	}
	
	@IBAction func touchDown(_ sender: Any) {
		animateButton()
	}
	
	private func animateButton(){
		UIView.animate(withDuration: 0.2,
					   animations: {
						self.btnScore.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
		},
					   completion: { _ in
						UIView.animate(withDuration: 0.2) {
							self.btnScore.transform = CGAffineTransform.identity
						}
		})
	}
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "gameOver", let destination = segue.destination as? GameOverVC{
			destination.phrase        = self.phrase
			destination.userScore     = self.score
			destination.expectedScore = self.occurances
		}
	}
	@IBAction func endSession(_ sender: Any) {
		performSegue(withIdentifier: "gameOver", sender: self)
	}
}
