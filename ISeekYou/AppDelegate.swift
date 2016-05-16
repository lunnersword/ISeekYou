//
//  AppDelegate.swift
//  ISeekYou
//
//  Created by lunner on 7/24/15.
//  Copyright (c) 2015 lunner. All rights reserved.
//

import UIKit


enum Preferece: String {
	case IsLogin = "IsLoginName"
	case IsFirstLaunch = "ISFirstLaunchName"
}
enum Identifiers: String {
	case LoginViewCTR = "LoginViewController"
	case RegisterAndLoginNavigationCTR = "RegisterAndLoginNavigationController"
	case TabViewNavigationCTR = "TabViewNavigationController"
}
enum Commands: String {
	case Login = "L"
	case Register = "R"
	case MessageToPersonal = "M"
	case MessageToGroup = "MG"
	case Logout = "O"
	case PersonalInformation = "PI"
	case VoiceToPersonal = "V"
	case VoiceToGroup = "VG"
	case ImageToPersonal = "I"
	case ImageToGroup = "IG"
}
enum PersonalInformations: String {
	case username = "username"
	case password = "password"
	case nickname = "nickname"
	case email = "email"
	case signature = "signature"
	case sex = "sex"
	case phone = "phone"
	case city = "city"
}

enum GlogalNames: String {
	case EOL = ":EOL"
	case WrapEOLWithSpace = " :EOL "
	case Success = "success"
	case Failure = "failure"
	case Inexistence = "inexistence"
	case Mismatch = "mismatch"
	case Exists = "exists"
}
enum Devices: String {
	case Phone = "phone"
	case PC = "PC"
	case Pad = "pad"
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
//		let host: String = "127.0.0.1"
//	let port: UInt32 = 7778
//	
	var window: UIWindow?
//
//	lazy var lineReceiver: LineReceiver = LineReceiver(host: host, port: port)

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		//register defaults values
		
		let userDefaults = NSUserDefaults.standardUserDefaults()
		let defaults = [Preferece.IsLogin.rawValue: false,
			Preferece.IsFirstLaunch.rawValue: true]
		userDefaults.registerDefaults(defaults)
		
		let isLogin = userDefaults.boolForKey(Preferece.IsLogin.rawValue)
		let isFirstLaunch = userDefaults.boolForKey(Preferece.IsFirstLaunch.rawValue)
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let firstViewController: UIViewController?
		//var lineReceiver: LineReceiver = LineReceiver(host: "127.0.0.1", port: 7777) //create the single LineReceiver instance
		//start line receiver run loop
		LineReceiverController.sharedLineReceiverController().lineReceiver?.start()
		if isLogin {
			window?.rootViewController = storyboard.instantiateViewControllerWithIdentifier(Identifiers.TabViewNavigationCTR.rawValue) as! UINavigationController
			firstViewController = (window?.rootViewController as! UINavigationController).topViewController
			// MARK: is logined. let the firstViewController start lineReceiver and send login message to server or do it here as below (do it in the view controller)
			/*
			lineReceiver.delegate = firstViewController as! LineReceiverDelegate
			lineReceiver.start()
			firstViewController.login() //here is just a pre
			*/
			
			
		} else if isFirstLaunch {
			window?.rootViewController = storyboard.instantiateViewControllerWithIdentifier(Identifiers.RegisterAndLoginNavigationCTR.rawValue) as! UINavigationController 
			firstViewController = (window?.rootViewController as! UINavigationController).topViewController
		} else {
			window?.rootViewController = storyboard.instantiateViewControllerWithIdentifier(Identifiers.LoginViewCTR.rawValue) as! LoginViewController
			firstViewController = window?.rootViewController
		}

		// MARK: start a LineReceiver, is not needed after getting the single instance of LineReceiver and setting its delete to self in every viewDidLoad of each view controller who is interact with net. First I want to create a class as a single LineReceiverDelegate, as the results of CFStreamCallBack to send message to the corresponding view controller, but it is more complecated than every single view controller perform the LineReceiverDelegate. Because in a single delegate class I have to determine which view controller now is active and every handle different messages, I have to parse message respectively.
//		var lineReceiver: LineReceiver = LineReceiver(host: "127.0.0.1", port: 7777)
//		lineReceiver.delegate = firstViewController as! LineReceiverDelegate
//		lineReceiver.start()
		
		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

