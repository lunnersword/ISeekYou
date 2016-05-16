//
//  LineReceiverController.swift
//  ISeekYou
//
//  Created by lunner on 8/27/15.
//  Copyright (c) 2015 lunner. All rights reserved.
//

import Foundation
@objc protocol LineReceiverBridgeDelegate {
	func lineReceived(line: String!)
	optional func lineReceiverConnectCompleted()
	func lineReceiverConnectError()
	func lineReceiverDisconnected()
	func lineReceiverErrorOccured(errorPtr: NSError!) 
	
}
class LineReceiverController: NSObject, LineReceiverDelegate {
	
	weak var delegate: LineReceiverBridgeDelegate?
	var lineReceiver: LineReceiver?
	static var lineReceiverController: LineReceiverController?
	init(host: String, port: UInt32) {
		self.lineReceiver = LineReceiver(host: host, port: port)
		
	}
	static func sharedLineReceiverController() -> LineReceiverController {
		if lineReceiverController == nil {
			lineReceiverController = LineReceiverController(host: "127.0.0.1", port: 7777)
			lineReceiverController?.lineReceiver?.delegate = lineReceiverController
			//lineReceiverController?.lineReceiver?.start()
		}
		return lineReceiverController!
	}
	
	func sendLine(line: String, messageSendCompletion: ((Bool) -> Void)?, completion: ((Bool) -> Void)?) {
		lineReceiver?.pushToMessagePool(line, messageSendCompletion: messageSendCompletion, completion: completion)
	}
	func getReadStreamStatus() -> CFStreamStatus? {
		return lineReceiver?.getReadStreamStatus()
	}
	func getWriteStreamStatus() -> CFStreamStatus? {
		return lineReceiver?.getWriteStreamStatus()
	}
	// MARK: LineReceiverDelegate
	func lineReceived(line: String!) {
		NSLog("line in Controller: %@", line)
		delegate?.lineReceived(line)
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
