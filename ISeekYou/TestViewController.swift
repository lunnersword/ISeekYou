//
//  TestViewController.swift
//  ISeekYou
//
//  Created by lunner on 8/4/15.
//  Copyright (c) 2015 lunner. All rights reserved.
//

import Foundation
import UIKit
var lineReceiver: LineReceiver?
let host: String = "127.0.0.1"
let port: UInt32 = 7778
class TestViewController: UIViewController, LineReceiverDelegate {
	
	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var registerButton: UIButton!
	

	
	override func viewDidLoad() {
		super.viewDidLoad()
		if lineReceiver == nil {
			lineReceiver = (LineReceiver.lineReceiverWithHost(host, myPort: port) as! LineReceiver)
			lineReceiver?.delegate = self
			lineReceiver!.start()
		}
	}
	
	@IBAction func register(sender: AnyObject) {
		let username = usernameTextField.text
		let passwrod = passwordTextField.text
		var line = "R".stringByAppendingString(" ")
		line = line + username
		line = line + " "
		line = line + passwrod + " " + ":EOL"
		//" " + username + " " + passwrod + " "
		//void (^sendCompletion)(bool successed) = ^(
		lineReceiver?.pushToMessagePool(line, messageSendCompletion: {
			(successed: Bool) -> Void in
			if (successed) {
				NSLog("Send message %@ success", line);
			} else {
				NSLog("Send message %@ failed", line);
			}

		}, completion:{
			(successed: Bool) -> Void in
				if (successed) {
					NSLog("Push message %@ into message pool success", line);
				} else {
					NSLog("Push message %@ into message pool failed", line);
				}
		});
	}
	
	// MARK: perform LineReceiverDelegate
	/*
	- (void)lineReceiverConnectCompleted;
	- (void)lineReceiverConnectError;
	- (void)lineReceiverDisconnected;
	- (void)lineReceiverErrorOccured:(NSError *) errorPtr;
	
	- (void)lineReceived:(NSString*) line;
*/

	func lineReceived(line: String!) {
		NSLog("%@", line)
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
