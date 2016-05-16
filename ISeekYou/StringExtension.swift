//
//  NSStringExtension.swift
//  ISeekYou
//
//  Created by lunner on 8/30/15.
//  Copyright (c) 2015 lunner. All rights reserved.
//

import Foundation
extension String {
	func isMatchRegex(regex: String) -> Bool {
		let str = self as NSString
		let range: NSRange = str.rangeOfString(regex, options: NSStringCompareOptions.RegularExpressionSearch)
		if range.location != NSNotFound && range.location == 0 && range.length == str.length {
			return true
		}
		return false
	}
}