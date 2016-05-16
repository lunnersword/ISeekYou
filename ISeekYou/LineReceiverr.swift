//
//  LineReceiver.swift
//  ISeekYou
//
//  Created by lunner on 8/4/15.
//  Copyright (c) 2015 lunner. All rights reserved.
//

import Foundation
import CoreFoundation
protocol LineReceiverDelegater {
	func lineReceiverConnectFailed(errorString: String)
}
func callback(stream: CFReadStreamRef, event: CFStreamEventType, myPtr: UnsafeMutablePointer<Void>)  -> Void {
	
}

let socketCallback: CFReadStreamClientCallBack = callback as! CFReadStreamClientCallBack

class LineReceiverRR {
	let host: String
	let port: UInt 
	var delegate: LineReceiverDelegate?
	var buffer = [UInt8](count: 512, repeatedValue: 0)
	let bufferSize = 512
	init(host: String, port: UInt) {
		self.host = host
		self.port = port 
		
	}
	
	func start() {
		
	}
	
	func loadCurrentStatus() {
		var streamClientContext: CFStreamClientContext = CFStreamClientContext(version: 0, info: self as! UnsafeMutablePointer<Void>, retain: nil, release: nil, copyDescription: nil)
		var registeredEvents: CFOptionFlags = 
		CFStreamEventType.OpenCompleted.rawValue | CFStreamEventType.HasBytesAvailable.rawValue | CFStreamEventType.ErrorOccurred.rawValue | CFStreamEventType.EndEncountered.rawValue
		//var readStream = UnsafeMutablePointer<Unmanaged<CFReadStream>?>()
		//var writeStream =  UnsafeMutablePointer<Unmanaged<CFWriteStream>?>()
		//var readStream :CFReadStreamRef
		var readStream = CFReadStreamCreateWithBytesNoCopy(kCFAllocatorDefault, buffer, bufferSize, kCFAllocatorNull)
		CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, self.host as CFString!, UInt32(self.port), readStream as! UnsafeMutablePointer<Unmanaged<CFReadStream>?>, nil)
		if CFReadStreamSetClient(readStream, registeredEvents, socketCallback, streamClientContext as! UnsafeMutablePointer<CFStreamClientContext>) {
			CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes)
		} else {
			NSLog("Failed to assign callback method")
			self.delegate?.lineReceiverFailed("Unable to connect to server")
			return
		}
		
		//open the stream for reading
		if CFReadStreamOpen(readStream) {
			NSLog("Failed to open read stream")
			self.delegate?.lineReceiverConnectFailed("Unable to connect to server")
			return 
		}
		
		if let error = CFReadStreamCopyError(readStream as CFReadStreamRef) {
			if CFErrorGetCode(error) != 0 {
				NSLog("Failed to connect stream; error '%@' (code %ld)", CFErrorGetDomain(error) as NSString, CFErrorGetCode(error))
			}
			self.delegate?.lineReceiverConnectFailed("Unable to connect to server")
			return
		}
		
		NSLog("Successfully connected to %@", self.host + ":" + String(self.port))
		
		//start processing
		CFRunLoopRun()
		
		
	}
}