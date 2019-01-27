//
//  SelectPhraseVC.swift
//  CUHackit2019
//
//  Created by John Garrett on 1/26/19.
//  Copyright © 2019 John Garrett. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SelectPhraseVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
	@IBOutlet var phrasesCV: UICollectionView!
	var classID:String?
	private var phrases = [String]()
	private var phraseToSend:String?
	lazy private var ref = Database.database().reference().child("Classes").child(classID!).child("Phrases")

    override func viewDidLoad() {
		loadPhrases()
        super.viewDidLoad()
    }
	
	private func loadPhrases(){
		if classID == nil{
			self.alert("Error, no class id.")
			return
		}
		
		ref.observe(.value) { (snapshot) in
			for phrase in snapshot.children.allObjects as! [DataSnapshot] {
				self.phrases.append(phrase.key)
				self.phrasesCV.reloadData()
			}
		}
		
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if phrases.count == 0{
			self.alert("Your phrases yet, ask your professor to set some up!")
		}
		return phrases.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "phraseCell", for: indexPath) as? PhraseCell{
			
			cell.lblPhrase.text = phrases[indexPath.item]
			return cell
		}
		return UICollectionViewCell()
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		print(phrases[indexPath.item])
		phraseToSend = phrases[indexPath.item]
		performSegue(withIdentifier: "toMainVC", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "toMainVC", let destination = segue.destination as? MainVC{
			destination.phrase = self.phraseToSend
		}
	}
}
