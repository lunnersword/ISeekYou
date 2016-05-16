//
//  AdditionalRegisterViewController.swift
//  ISeekYou
//
//  Created by lunner on 8/25/15.
//  Copyright (c) 2015 lunner. All rights reserved.
//

import UIKit

class AdditionalRegisterViewController: UIViewController {
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var profileImageView: UIImageView!
	@IBOutlet weak var manOrWomanSeg: UISegmentedControl!
	@IBOutlet weak var nicknameTextField: UITextField!
	@IBOutlet weak var finishRegisterButton: UIButton!
	var username: String?
	var nickname: String? {
		didSet {
			if nickname != nil && manOrFemal != nil {
				finishRegisterButton.enabled = true
			} else {
				finishRegisterButton.enabled = false
			}
		}
	}
	var manOrFemal: Int? = 0 {
		didSet {
			if manOrFemal != nil && nickname != nil {
				finishRegisterButton.enabled = true
			} else {
				finishRegisterButton.enabled = false
			}
		}
	}
	var profileImage: UIImage?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
        // Do any additional setup after loading the view.
		usernameLabel.text = username
		
		let tap = UITapGestureRecognizer(target: self, action: "profileImageViewTouched:")
		
		tap.numberOfTapsRequired = 1
		tap.numberOfTouchesRequired = 1
		profileImageView.addGestureRecognizer(tap)
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
	
	// MARK: IBActions
	@IBAction func nicknameTextFieldEndEditing(sender: AnyObject) {
		if let nickname = (sender as! UITextField).text {
			let regex = "\\S{1,13}]"
			let predicate: NSPredicate = NSPredicate(format: "SELF MATCHS \(regex)")
			let isValid = predicate.evaluateWithObject(nickname)
			if isValid {
				self.nickname = nickname as String
			} else {
				// TODO: handle wrong input for nickname
			}
		}
	}
	
	@IBAction func finishButtonTouched(sender: AnyObject) {
		// TODO: send additional personal information to server
		
		// TODO: segue to tab viewcontroller
	}

	@IBAction func sexSelected(sender: UISegmentedControl!) {
		manOrFemal = sender.selectedSegmentIndex
	}
	// MARK: Actions
	func profileImageViewTouched(gesture: UITapGestureRecognizer) {
		// TODO: show a image picker view let user pick a profile
	}
	
	// MARK: LineReceiverDelegate here not handle the connect, just go into tab after touched the finishButton.
	/*
	func lineReceived(line: String!) {
		
	}
	func lineReceiverConnectCompleted() {
		
	}
	func lineReceiverConnectError() {
		
	}
	func lineReceiverDisconnected() {
		
	}
	func lineReceiverErrorOccured(errorPtr: NSError!) {
		
	}*/

}
