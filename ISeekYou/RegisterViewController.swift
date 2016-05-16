//
//  RegisterViewController.swift
//  ISeekYou
//
//  Created by lunner on 7/29/15.
//  Copyright (c) 2015 lunner. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, LineReceiverBridgeDelegate {

	@IBOutlet weak var seekNameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var registerButton: UIButton!
	
	var lineReceiverController: LineReceiverController!
	var userName: String? {
		didSet {
			if userName != nil && password != nil {
				registerButton.enabled = true
			} else {
				registerButton.enabled = false
			}
		}
	}
	var password: String? {
		didSet {
			if password != nil && userName != nil  {
				registerButton.enabled = true
			} else {
				registerButton.enabled = false
			}
		}
	}
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//		lineReceiver = LineReceiver.lineReceiverWithHost("", myPort: 0) as! LineReceiver
//		lineReceiver.delegate = self
//		if !lineReceiver.isStarted {
//			lineReceiver.start()
//		}
		lineReceiverController = LineReceiverController.sharedLineReceiverController()
		lineReceiverController.delegate = self
		//registerButton.enabled = false
 }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: IBActions
	

	@IBAction func usernameTextFieldEndEditing(sender: UITextField) {
		if let name: NSString = seekNameTextField.text {
			/*
			var error: NSError?
			let range = NSMakeRange(0, name.length)
		
			//string to use regular
			let firstMatchRange = name.rangeOfString("[0-9a-zA-Z]{6,12}", options: NSStringCompareOptions.RegularExpressionSearch)
			//end
			//use NSReglarExpression class
			let regex: NSRegularExpression = NSRegularExpression(pattern: "[0-9a-zA-Z]{6,12}", options: nil, error: &error)!
			let firstRange = regex.rangeOfFirstMatchInString(name as String, options: nil, range: range)
			if range.location != firstRange.location && range.length != firstRange.length {
				// TODO: handle wrong input for username
			} else {
				userName = name as String
			}
			*/
			//use NSPredicate
			let regex = "[a-z0-9A-Z]{1,12}"
			let predicate: NSPredicate = NSPredicate(format: "SELF MATCHS \(regex)")
			let isValid = predicate.evaluateWithObject(name)
			if isValid {
				// set name to username
				userName = name as String
			} else {
				// TODO: handle wrong input for username
				NSLog("username invalid")
			}

		}
	}

	@IBAction func passwordTextFieldDidEndEditing(sender: UITextField!) {
		let password: NSString = sender.text 
			let regex = "\\S{6,40}]"
			let predicate: NSPredicate = NSPredicate(format: "SELF MATCHS \(regex)")
			if predicate.evaluateWithObject(password) {
				// set password
				self.password = password as String
				NSLog(self.password!)
			} else {
				// TODO: handle wrong input for password
				NSLog("password invalid")
			}
			
		
	}
	@IBAction func registerButtonTouched(sender: UIButton!) {
		// TODO: send register message to server
		var line = "R \(userName) \(password) :EOF "
		lineReceiverController.sendLine(line, messageSendCompletion: {
			(successed: Bool) -> Void in
			if successed {
				NSLog("Send message %@ success", line);// just send message success
			} else {
				NSLog("Send message %@ failed", line);
			}
			}, completion: {
				(successed: Bool) -> Void in
				if successed {
					NSLog("Push message %@ into message pool success", line);
				} else {
					NSLog("Push message %@ into message pool failed", line);
				}
		})
		
		
	}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
	/*
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "AdditionalRegister" {
			let controller = segue.destinationViewController as! AdditionalRegisterViewController
			controller.username = self.userName
		}
	}*/
	
	// MARK: perform LineReceiverDelegate
	func lineReceived(line: String!) {
		// TODO: if the line received is: R code... handle it otherwise ignore it.
		NSLog("%@", line)
	
		if line.compare("R success :EOF ", options: nil, range: nil, locale: nil) == NSComparisonResult.OrderedSame {
			//register success perform segue.
			//performSegueWithIdentifier("AdditionalRegister", sender: nil)
			let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
			var additionalRegisterController: AdditionalRegisterViewController = storyboard.instantiateViewControllerWithIdentifier("AdditionalRegisterViewController") as! AdditionalRegisterViewController
			additionalRegisterController.username = userName
			self.showViewController(additionalRegisterController, sender: nil)
		} else if line.compare("R failure :EOF ", options: nil, range: nil, locale: nil) == NSComparisonResult.OrderedSame {
			var alert = UIAlertController(title: "Register", message: "Register failed: Unknow reasons", preferredStyle: .ActionSheet)
			alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
			alert.popoverPresentationController?.sourceView = self.registerButton
			alert.popoverPresentationController?.sourceRect = self.registerButton.frame
			self.presentViewController(alert, animated: true, completion: nil)
		} else if line.compare("R exists :EOF ", options: nil, range: nil, locale: nil) == NSComparisonResult.OrderedSame {
			var alert = UIAlertController(title: "Register", message: "Register failed: User exists", preferredStyle: .ActionSheet)
			alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
			alert.popoverPresentationController?.sourceView = self.registerButton
			alert.popoverPresentationController?.sourceRect = self.registerButton.frame
			self.presentViewController(alert, animated: true, completion: nil)
		} 
			// ignore other msg
		
	}
	func lineReceiverConnectCompleted() {
		NSLog("connect completed")
	}

	func lineReceiverConnectError() {
		NSLog("Connect error")
	}
	func lineReceiverDisconnected() {
		NSLog("Disconnected")
	}
	func lineReceiverErrorOccured(errorPtr: NSError!) {
		NSLog("Error Ocurred")
	}

}
