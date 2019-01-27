//
//  GameOverVC.swift
//  CUHackit2019
//
//  Created by John Garrett on 1/27/19.
//  Copyright © 2019 John Garrett. All rights reserved.
//

import UIKit

class GameOverVC: UIViewController {

	var userScore:Int?
	var expectedScore:Int?
	var phrase:String?
	
	@IBOutlet var btnDone:          UIButton!
	@IBOutlet var lblPhrase:        UILabel!
	@IBOutlet var lblUserScore:     UILabel!
	@IBOutlet var lblFinalScore:    UILabel!
	@IBOutlet var lblExpectedScore: UILabel!
	
	override func viewDidLoad() {
		lblUserScore.text = String(userScore ?? 0)
		lblExpectedScore.text = String(expectedScore ?? 0)
		

		let difference = abs((userScore ?? 0) - (expectedScore ?? 0))
		lblFinalScore.text = String((userScore ?? 0) - Int(difference))
		
		super.viewDidLoad()
    }
}
