//
//  MessageHandle.h
//  ISeekYou
//
//  Created by lunner on 8/5/15.
//  Copyright (c) 2015 lunner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageHandle: NSObject

@property(readonly) NSString* message;
@property(copy) void (^handle)(BOOL success);
+ (id)messageHandleWithMessage:(NSString*) message handle:(void (^)(BOOL))handle;
- (id)initWithMessage:(NSString*)message sendCompletion:(void (^)(BOOL))handle;

@end