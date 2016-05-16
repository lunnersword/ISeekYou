//
//  MessageHandle.m
//  ISeekYou
//
//  Created by lunner on 8/5/15.
//  Copyright (c) 2015 lunner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageHandle.h"

@implementation MessageHandle

//@synthesize message = _message;

+ (id)messageHandleWithMessage:(NSString*) message handle:(void (^)(BOOL))handle {
	return [[self alloc] initWithMessage:message sendCompletion:handle];
}
- (id)initWithMessage:(NSString*)message sendCompletion:(void (^)(BOOL))handle {
	self = [super init];
	if (self){
		_message = message;
		_handle = handle;
	}
	return self;
}

@end