//
//  LoginViewController.swift
//  ISeekYou
//
//  Created by lunner on 8/25/15.
//  Copyright (c) 2015 lunner. All rights reserved.
//

import UIKit

class ConvenienceLoginViewController: UIViewController, LineReceiverDelegate {


	@IBOutlet weak var profileImageView: UIImageView!	
	
	@IBOutlet weak var otherUsersButton: UIButton!
	
	@IBOutlet weak var nickNameLabel: UILabel!
	
	@IBOutlet weak var loginButton: UIButton!
	@IBOutlet weak var passwordTextField: UITextField!
   
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

	@IBAction func otherUsersButtonTouched(sender: AnyObject) {
		// TODO: show the other users, in popover or alert, popover is prefered
	}
	@IBAction func moreButtonTouched(sender: AnyObject) {
		// TODO: show other options like login as another user never login current device before, register a new user.
		
	}
	@IBAction func passwordTextFieldEndEditing(sender: AnyObject) {
		let textField = sender as! UITextField
		if let password = textField.text {
			let regex = "\\S{6,40}]"
			let predicate: NSPredicate = NSPredicate(format: "SELF MATCHS \(regex)")
			if predicate.evaluateWithObject(password) {
				// TODO: compare current password with that stored in Core Data. only the lastest login username and password is stored in UserDefaults
				
				//if matchs with Core Data, send a login message to the serve
				
				
				
			} else {
				// TODO: handle wrong input for password
			}
		}
	}
	
	// MARK: perform LineReceiverDelegate
	
	func lineReceived(line: String!) {
		
	}
	func lineReceiverConnectCompleted() {
		
	}
	func lineReceiverConnectError() {
		
	}
	func lineReceiverDisconnected() {
		
	}
	func lineReceiverErrorOccured(errorPtr: NSError!) {
		
	}
}
