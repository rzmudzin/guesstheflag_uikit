//
//  FlagViewController.swift
//  GuessTheFlag
//
//  Created by Rob Zmudzinski on 5/27/22.
//

import UIKit

class FlagViewController: UIViewController {
//    let prefix = "SF_"
    let prefix = ""
	var countries = ["estonia", "france", "germany", "ireland", "italy", "nigeria", "poland", "russia", "spain", "uk", "us"]
    var states = [
        "Alabama":    "Montgomery",
        "Montana":    "Helena",
        "Alaska":    "Juneau",
        "Nebraska":    "Lincoln",
        "Arizona":    "Phoenix",
        "Nevada":    "Carson City",
        "Arkansas":    "Little Rock",
        "New Hampshire":    "Concord",
        "California":    "Sacramento",
        "New Jersey":    "Trenton",
        "Colorado":    "Denver",
        "New Mexico":    "Santa Fe",
        "Connecticut":    "Hartford",
        "New York":    "Albany",
        "Delaware":    "Dover",
        "North Carolina":    "Raleigh",
        "Florida":    "Tallahassee",
        "North Dakota":    "Bismarck",
        "Georgia":    "Atlanta",
        "Ohio":    "Columbus",
        "Hawaii":    "Honolulu",
        "Oklahoma":    "Oklahoma City",
        "Idaho":    "Boise",
        "Oregon":    "Salem",
        "Illinois":    "Springfield",
        "Pennsylvania":    "Harrisburg",
        "Indiana":    "Indianapolis",
        "Rhode Island":    "Providence",
        "Iowa":    "Des Moines",
        "South Carolina":    "Columbia",
        "Kansas":    "Topeka",
        "South Dakota":    "Pierre",
        "Kentucky":    "Frankfort",
        "Tennessee":    "Nashville",
        "Louisiana":   "Baton Rouge",
        "Texas":    "Austin",
        "Maine":    "Augusta",
        "Utah":    "Salt Lake City",
        "Maryland":    "Annapolis",
        "Vermont":    "Montpelier",
        "Massachusetts":    "Boston",
        "Virginia":    "Richmond",
        "Michigan":    "Lansing",
        "Washington":    "Olympia",
        "Minnesota":    "St. Paul",
        "West Virginia":    "Charleston",
        "Mississippi":    "Jackson",
        "Wisconsin":    "Madison",
        "Missouri":    "Jefferson City",
        "Wyoming":    "Cheyenne"
    ]
	var maxQuestions = 5
	var questionsAsked = 0
	var answeredCorrectly = 0
	var correctAnswer = 0
	
	@IBOutlet var button1: UIButton!
	@IBOutlet var button2: UIButton!
	@IBOutlet var button3: UIButton!
	@IBAction func onFlagTap(_ sender: UIButton) {
		if questionsAsked < maxQuestions {
			questionsAsked += 1
			if sender.tag == correctAnswer {
				answeredCorrectly += 1
				let ac = UIAlertController(title: "Correct", message: "Your score is \(answeredCorrectly) out of \(questionsAsked) questions answered correctly. \nThere are \(maxQuestions-questionsAsked) questions remaining", preferredStyle: .alert)
				ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: { _ in
					self.askQuestion()
				}))
				present(ac, animated: true)
			} else {
				let ac = UIAlertController(title: "Incorrect", message: "You selected the flag of \(countries[sender.tag])", preferredStyle: .alert)
				ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: { _ in
					self.askQuestion()
				}))
				present(ac, animated: true)
			}
		}
	}
	override func viewDidLoad() {
        super.viewDidLoad()

		button1.layer.borderWidth = 1
		button2.layer.borderWidth = 1
		button3.layer.borderWidth = 1
		
		button1.layer.borderColor = UIColor.lightGray.cgColor
		button2.layer.borderColor = UIColor.lightGray.cgColor
		button3.layer.borderColor = UIColor.lightGray.cgColor
        
//        let flagOneLabel = UILabel()
//        flagOneLabel.text = "Test"
//        flagOneLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(flagOneLabel)
//        NSLayoutConstraint.activate([
//            flagOneLabel.topAnchor.constraint(equalTo: button1.bottomAnchor, constant: 5),
//            flagOneLabel.centerXAnchor.constraint(equalTo: button1.centerXAnchor)
//        ])
        
		
		let navbarButton = UIBarButtonItem(title: "New Game", style: .plain, target: self, action: #selector(newGame))
		navigationItem.rightBarButtonItem = navbarButton
		navigationItem.rightBarButtonItem?.isEnabled = true
		
		askQuestion()
    }
	
	@objc func newGame() {
		let ac = UIAlertController(title: "New Game", message: "Start a new game?", preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
			self.questionsAsked = 0
			self.answeredCorrectly = 0
			self.askQuestion()
		}))
		ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
			
		}))
		present(ac, animated: true)
	}

	func displayGameOver() {
		let ac = UIAlertController(title: "Game Over", message: "Final Score: You answered \(answeredCorrectly) of \(maxQuestions) correctly.", preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
			
		}))
		present(ac, animated: true)
	}
	
	func askQuestion() {
		if questionsAsked == maxQuestions {
			displayGameOver()
		} else {
			countries.shuffle()
			correctAnswer = Int.random(in: 0...2)
	//		var countryName = countries[correctAnswer]
	//		countryName = countryName.prefix(1).uppercased() + countryName.dropFirst()
			title = countries[correctAnswer].uppercased()
			button1.setImage(UIImage(named: "\(prefix)\(countries[0])"), for: .normal)
			button2.setImage(UIImage(named: "\(prefix)\(countries[1])"), for: .normal)
			button3.setImage(UIImage(named: "\(prefix)\(countries[2])"), for: .normal)
		}
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
