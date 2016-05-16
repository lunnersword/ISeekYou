//
//  LineReceiver.h
//  ISeekYou
//
//  Created by lunner on 8/4/15.
//  Copyright (c) 2015 lunner. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LineReceiverDelegate <NSObject>
@optional
- (void)lineReceiverConnectCompleted;
@required
- (void)lineReceiverConnectError;
- (void)lineReceiverDisconnected;
- (void)lineReceiverErrorOccured:(NSError *)errorPtr;
- (void)lineReceived:(NSString*)line;

@end


@interface LineReceiver: NSObject

@property(readonly) NSString *host;
@property(readonly) unsigned int port;
@property NSString *delimiter;
@property NSUInteger maxLength;
//@property BOOL isStarted;
@property BOOL paused;
@property(weak) id<LineReceiverDelegate> delegate;


+ (id)sharedLineReceiver;
+ (id)lineReceiverWithHost:(NSString*)host myPort:(unsigned int)port;
- (id)initWithHost:(NSString*)host port:(unsigned int)port;
- (void)start;
- (void)closeConnection;
- (void)pushToMessagePool:(NSString *)line messageSendCompletion:(void (^)(bool))sendCompletion completion:(void (^)(bool))completion;
- (CFStreamStatus)getReadStreamStatus;
- (CFStreamStatus)getWriteStreamStatus;

@end