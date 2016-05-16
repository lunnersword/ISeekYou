//
//  LoginViewController.swift
//  ISeekYou
//
//  Created by lunner on 8/26/15.
//  Copyright (c) 2015 lunner. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, LineReceiverBridgeDelegate, UITextFieldDelegate {

	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var loginButton: UIButton!
	var lineReceiverController: LineReceiverController?
	var username: String?/* {
		didSet {
			if username != nil && password != nil {
				loginButton.enabled = true
			} else {
				loginButton.enabled = false
			}
		}
	}*/
	
	var password: String? /*{
		didSet {
			if password != nil && username != nil {
				loginButton.enabled = true
			} else {
				loginButton.enabled = false
			}
		}
	}*/
    override func viewDidLoad() {
        super.viewDidLoad()
		passwordTextField.secureTextEntry = true
		passwordTextField.returnKeyType = UIReturnKeyType.Go
		passwordTextField.delegate = self

		usernameTextField.returnKeyType = UIReturnKeyType.Next
		usernameTextField.delegate = self
        // Do any additional setup after loading the view.
		lineReceiverController = LineReceiverController.sharedLineReceiverController()
		lineReceiverController?.delegate = self
		var tap = UITapGestureRecognizer(target: self , action: "dismissKeyboard:")
		self.view.addGestureRecognizer(tap)
		
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
	
	@IBAction func usernameTextFieldEndEditing(sender: UITextField) {
		let name = sender.text;
		/*
		let regex: NSString = "[a-z0-9A-Z]{1,12}"
		let predicate: NSPredicate = NSPredicate(format: "SELF MATCHS %@", regex)
		let isValid = predicate.evaluateWithObject(name)
		*/
//		let isValid = name.isMatchRegex("[a-z0-9A-Z]{1,12}")
//		if isValid {
			// set name to username
			self.username = name as String
//		} else {
//			// TODO: handle wrong input for username
//			var alert = UIAlertController(title: "用户名不符合要求", message: "请输入1到12只包括英文字母和数字的用户名", preferredStyle: .Alert)
//			alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
//			presentViewController(alert, animated: true, completion: nil)
//		}
	}
	@IBAction func passwordTextFieldEndEditing(sender: AnyObject) {
		if let password = (sender as! UITextField).text {
			//let regex = "\\S{6,40}]"
			//let predicate: NSPredicate = NSPredicate(format: "SELF MATCHS \(regex)")
			//predicate.evaluateWithObject(password)
//			if  password.isMatchRegex("\\S{6,40}"){
				// TODO: compare current password with that stored in Core Data. only the lastest login username and password is stored in UserDefaults
				
				//if matchs with Core Data, send a login message to the serve
				self.password = password
				
				
//			} else {
//				// TODO: handle wrong input for password
//				var alert = UIAlertController(title: "密码不符合要求", message: "密码长度必须6与40之间，且不包括空白字符", preferredStyle: .Alert)
//				alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil /*{
//					[unowned self] (action: UIAlertAction!) -> Void in
//					self.passwordTextField.selected = true
//				}*/))
//				presentViewController(alert, animated: true, completion: nil)
//			}

		}
	}
	@IBAction func loginButtonTouched(sender: AnyObject) {
		// TODO: send login message to server,
		// because login button is enabled all the time, so ths button may touched when textfield still in editing, /*Assertion failure in -[UIKeyboardTaskQueue waitUntilAllTasksAreFinished], /SourceCache/UIKit_Sim/UIKit-3347.44.2/Keyboard/UIKeyboardTaskQueue.m:374  UIKeyboardTaskQueue waitUntilAllTasksAreFinished] may only be called from the main thread. */. make text field resign its first responder status, textFieldShouldEndEditing: delegate func will called, it return true indicate that editing should stop
		usernameTextField.resignFirstResponder()
		passwordTextField.resignFirstResponder()
		
		NSLog("loginButtonTouched")
		if username == nil {
			//
			var alert = UIAlertController(title: "用户名不能为空", message: "请输入1到12只包括英文字母或数字的用户名", preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
			presentViewController(alert, animated: true, completion: nil)
		} else if password == nil {
			var alert = UIAlertController(title: "密码不能为空", message: "密码长度必须6与40之间，且不包括空白字符", preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
			presentViewController(alert, animated: true, completion: nil)

			
		} else if !username!.isMatchRegex("[a-z0-9A-Z]{1,12}") {
			var alert = UIAlertController(title: "用户名错误", message: "请输入1到12只包括英文字母或数字的用户名", preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
			presentViewController(alert, animated: true, completion: nil)
			

		} else if !password!.isMatchRegex("\\S{6,40}") {
			var alert = UIAlertController(title: "密码错误", message: "密码长度必须6与40之间，且不包括空白字符", preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
			presentViewController(alert, animated: true, completion: nil)
		} else {
			let line = "L \(self.username!) \(self.password!) :EOL "
			lineReceiverController?.sendLine(line , messageSendCompletion: nil, completion: {
				(successed: Bool) in
				if !successed {
					var alert = UIAlertController(title: "Login failed", message: "Failed put message into send pool", preferredStyle: .Alert)
					alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
					self.presentViewController(alert, animated: true, completion: nil)
				}
			})

		}
	}
	
	// MAKE: dismiss keyboard
	func dismissKeyboard(gesture: UITapGestureRecognizer) {
		view.endEditing(false)
	}
	// MAKE: UITextFieldDelegate
	func textFieldShouldEndEditing(textField: UITextField) -> Bool {
		return true
	}
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		// TODO: Next, GO
		return true
	}
	
	// MAKE: LineReceiverDelegate
	func lineReceived(line: String!) {
		NSLog("line in LoginController: %@", line)
		let lineBack: NSString = line as NSString
		if lineBack.isEqualToString("L success :EOL ") {
			// segue to tab view
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let tabNavigationController = storyboard.instantiateViewControllerWithIdentifier("TabViewNavigationController") as! UINavigationController
//			let tabBarController = storyboard.instantiateViewControllerWithIdentifier("TabBarController") as! TabBarController
//			tabNavigationController.pushViewController(tabBarController, animated: false)

			var window = (UIApplication.sharedApplication().delegate as! AppDelegate).window
			window?.rootViewController = tabNavigationController
		} else if lineBack.isEqualToString("L inexistence :EOL ") {
			//用户名不存在
			var alert = UIAlertController(title: "登录失败", message: "用户名不存在", preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
			presentViewController(alert, animated: true, completion: nil)
						
		} else if lineBack.isEqualToString("L mismatch :EOL ") {
			var alert = UIAlertController(title: "登录失败", message: "用户名与密码不匹配", preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
			presentViewController(alert, animated: true, completion: nil)
			
		} else {
			var alert = UIAlertController(title: "登录失败", message: nil, preferredStyle: .Alert)
			alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
			presentViewController(alert, animated: true, completion: nil)
		}
	}
	func lineReceiverConnectCompleted() {
		NSLog("ConnectCompleted")
		
	}
	func lineReceiverConnectError() {
		NSLog("ConnectError")
		
	}
	func lineReceiverDisconnected() {
		NSLog("Disconnected")
	}
	func lineReceiverErrorOccured(errorPtr: NSError!) {
		NSLog("ErrorOccured")
	}
}
