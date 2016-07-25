//
//  LineReceiver.m
//  ISeekYou
//
//  Created by lunner on 8/4/15.
//  Copyright (c) 2015 lunner. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "LineReceiver.h"
#import "MessageHandle.h"
#import <CoreFoundation/CoreFoundation.h> 
#include <sys/socket.h> 
#include <netinet/in.h>

#define BufferSize 512

@interface LineReceiver() 

@property NSMutableArray *messagePool;
@property dispatch_semaphore_t semaphore;//semaphore for messagePool
- (void)setupReadStream;
- (void)setupWriteStream;
//- (void)setupWriteStream; 
- (void)didFinishReceivingData;

@end


@implementation LineReceiver {
	CFSocketRef		socket;
	NSMutableString	*buffer;
	CFWriteStreamRef	writeStream;
	CFReadStreamRef	readStream;
	BOOL busyReceiving;
	 //
	CFRunLoopRef readStreamRunLoop;
	CFRunLoopRef writeStreamRunLoop;
	CFStreamClientContext clientContext;

}
@synthesize delegate;


+ (LineReceiver*)sharedLineReceiver {
	return [self lineReceiverWithHost:@"127.0.0.1" myPort:7777];
}
+ (LineReceiver*)lineReceiverWithHost:(NSString *)host myPort:(unsigned int)port {
	static LineReceiver *localInstance = nil;
	static dispatch_once_t predicate;//static 变量只进行一次初始化
	dispatch_once(&predicate, ^{
		localInstance = [ [self alloc] initWithHost:host port:port];
	});
	return localInstance;
}

- (id)initWithHost:(NSString *)host port:(unsigned int)port {
	self = [super init];
	if (self != nil) {
		_host = host;
		_port = port;
		_delimiter = @"\r\n";
		_maxLength = 16384;
		busyReceiving = FALSE;
		_semaphore = dispatch_semaphore_create(1);
		_messagePool = [[NSMutableArray alloc] initWithCapacity:10];
		//_isStarted = FALSE;
		_paused = FALSE;
		
	}
	return self;
}

//+ (id)sharedLineReceiver:(NSString *) 

void readSocketCallback(CFReadStreamRef stream, CFStreamEventType event, void *myPtr) {
	LineReceiver *controller = (__bridge LineReceiver*)myPtr;
	
	switch(event) {
		case kCFStreamEventHasBytesAvailable:
			 //read bytes until there are no more
			NSLog(@"HasBytesAvailable\n");
			while (CFReadStreamHasBytesAvailable(stream)) {
				UInt8 buffer[BufferSize];
				CFIndex numBytesRead = CFReadStreamRead(stream, buffer, BufferSize);
				
				[controller dataReceived:[[NSString alloc] initWithBytes:buffer length:numBytesRead encoding:NSUTF8StringEncoding]];
			}
			
			break;
			
		case kCFStreamEventErrorOccurred: {
			CFErrorRef error = CFReadStreamCopyError(stream);
			
			if (error != NULL) {
				if (CFErrorGetCode(error) != 0) {
					NSLog(@"Failed while reading stream; error '%@' (code %ld)", (__bridge NSString*)CFErrorGetDomain(error), CFErrorGetCode(error));
				}
				
				CFRelease(error);
			}
			
			if ([controller.delegate respondsToSelector:@selector(networkingResultsDidFail:)]) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[controller.delegate lineReceiverErrorOccured:@"An unexpected error occurred while reading from the server."];
				});
				[controller closeConnection];
			}
			
			break;
		}
			
		case kCFStreamEventEndEncountered:
			[controller didFinishReceivingData];
			[controller closeConnection];
						
			break;
		case kCFStreamEventOpenCompleted:
			[controller.delegate lineReceiverConnectCompleted];
		default:
			break;
	}
}

void writeSocketCallback(CFWriteStreamRef stream, CFStreamEventType event, void *myPtr) {
	LineReceiver *controller = (__bridge LineReceiver*)myPtr;
	
	switch(event) {
		case kCFStreamEventCanAcceptBytes:
			while (CFWriteStreamCanAcceptBytes(stream)) {
				dispatch_semaphore_wait(controller.semaphore, 10*NSEC_PER_SEC);
				while ([controller.messagePool count] > 0) {
					MessageHandle *messageHandle = [controller.messagePool firstObject];
					int count = 0;
					BOOL succeed = FALSE;
					while (!succeed && count < 10) {
						succeed = [controller sendLine:messageHandle.message];
						count++;
					}
					[controller.messagePool removeObjectAtIndex:0];
					if (messageHandle.handle != NULL) {
						dispatch_async(dispatch_get_main_queue(), ^{
							messageHandle.handle(succeed);
						});
					}
					
				}
				dispatch_semaphore_signal(controller.semaphore);
			}
			break;
			
		case kCFStreamEventErrorOccurred: {
			CFErrorRef error = CFWriteStreamCopyError(stream);
			
			if (error != NULL) {
				if (CFErrorGetCode(error) != 0) {
					NSLog(@"Failed while writing stream; error '%@' (code %ld)", (__bridge NSString*)CFErrorGetDomain(error), CFErrorGetCode(error));
				}
				
				CFRelease(error);
			}
			
			if ([controller.delegate respondsToSelector:@selector(networkingResultsDidFail:)]) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[controller.delegate lineReceiverErrorOccured:@"An unexpected error occurred while writing from the server."];
				});
			}
			[controller closeConnection];
			break;
		}
			
		case kCFStreamEventEndEncountered:
			[controller didFinishReceivingData];
			
			[controller closeConnection];
			
			break;
		case kCFStreamEventOpenCompleted:
			[controller.delegate lineReceiverConnectCompleted];
		default:
			break;
	}
}


- (void) start {
	//_isStarted = TRUE;
	[self setupCommonStream];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		[self setupReadStream];
		//[self setupWriteStream];
		CFRunLoopRun();
		
	});
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		[self setupWriteStream];
		//[self setupWriteStream];
		CFRunLoopRun();
		
	});

}
- (void)setupCommonStream {
	CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)(_host),
									   _port,
									   &(readStream),
									   &(writeStream));
}
- (void)setupReadStream/*:(NSURL*)url*/ {
	// keep a reference to self to use for controller callbacks
	CFStreamClientContext ctx = {0, (__bridge void *)(self), NULL, NULL, NULL};
	// get callbacks for stream data, stream end, and any errors
	CFOptionFlags registeredEvents = (kCFStreamEventHasBytesAvailable | kCFStreamEventEndEncountered | kCFStreamEventErrorOccurred | kCFStreamEventOpenCompleted);
	
	
	// create a read-only socket
	//CFReadStreamRef readStream;
	
	
	// schedule the stream on the run loop to enable callbacks
	if (CFReadStreamSetClient(readStream, registeredEvents, readSocketCallback, &ctx)) {
		CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
	} else {
		NSLog(@"Failed to assign callback method");
		
		if ([self.delegate respondsToSelector:@selector(lineReceiverConnectError:)]) {
			[self.delegate lineReceiverConnectError];
		}
		
		
		return;
	}
	
	
	// open the stream for reading
	if (CFReadStreamOpen(readStream) == NO) {
		NSLog(@"Failed to open read stream");
		
		if ([self.delegate respondsToSelector:@selector(lineReceiverConnectError:)]) {
			[self.delegate lineReceiverConnectError];
		}
		
		return;
	}
	
	CFErrorRef error = CFReadStreamCopyError(readStream);
	
	if (error != NULL) {
		if (CFErrorGetCode(error) != 0) {
			NSLog(@"Failed to connect stream; error '%@' (code %ld)", (__bridge NSString*)CFErrorGetDomain(error), CFErrorGetCode(error));
		}
		
		CFRelease(error);
		
		if ([self.delegate respondsToSelector:@selector(lineReceiverConnectError:)]) {
			[self.delegate lineReceiverConnectError];
		}
		
		return;
	}
	
	NSLog(@"ReadStream successfully connected to %@", self.host);
	readStreamRunLoop = CFRunLoopGetCurrent();
	
	// start processing
	//CFRunLoopRun();
}
- (void)setupWriteStream {
	CFStreamClientContext ctx = {0, (__bridge void *)(self), NULL, NULL, NULL};
	// get callbacks for stream data, stream end, and any errors
	CFOptionFlags registeredWriteEvents = (kCFStreamEventCanAcceptBytes | kCFStreamEventEndEncountered | kCFStreamEventErrorOccurred | kCFStreamEventOpenCompleted );
	
	//CFReadStreamRef readStream;
//	CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)(_host),
//								_port,
//								&(readStream),
//								&(writeStream));
	
	
	// schedule the stream on the run loop to enable callbacks
	if (CFWriteStreamSetClient(writeStream, registeredWriteEvents, writeSocketCallback, &ctx)) {
		CFWriteStreamScheduleWithRunLoop(writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
		
	} else {
		NSLog(@"Failed to assign callback method");
		
		if ([self.delegate respondsToSelector:@selector(lineReceiverConnectError:)]) {
			[self.delegate lineReceiverConnectError];
		}
		
		
		return;
	}
	
	
	// open the stream for reading
	if (CFWriteStreamOpen(writeStream) == NO) {
		NSLog(@"Failed to open read stream");
		
		if ([self.delegate respondsToSelector:@selector(lineReceiverConnectError:)]) {
			[self.delegate lineReceiverConnectError];
		}
		
		return;
	}
	
	CFErrorRef writeError = CFReadStreamCopyError(readStream);
	
	if (writeError != NULL) {
		if (CFErrorGetCode(writeError) != 0) {
			NSLog(@"Failed to connect stream; error '%@' (code %ld)", (__bridge NSString*)CFErrorGetDomain(writeError), CFErrorGetCode(writeError));
		}
		
		CFRelease(writeError);
		
		if ([self.delegate respondsToSelector:@selector(lineReceiverConnectError:)]) {
			[self.delegate lineReceiverConnectError];
		}
		
		return;
	}
	
	NSLog(@"WriteSteam successfully connected to %@", self.host);
	writeStreamRunLoop = CFRunLoopGetCurrent();
	
	// start processing
	//CFRunLoopRun();
	
}

// MARK: get stream status
- (CFStreamStatus)getReadStreamStatus {
	return CFReadStreamGetStatus(readStream);
}
- (CFStreamStatus)getWriteStreamStatus {
	return CFWriteStreamGetStatus(writeStream);
}


//from outer thread to disconnect 
- (void) closeConnection {
	dispatch_time_t timeout = 5;
	dispatch_semaphore_wait(_semaphore, 5*NSEC_PER_SEC);
	CFWriteStreamClose(writeStream);
	// clean up the stream
	CFReadStreamClose(readStream);
	
	// stop processing callback methods
	CFReadStreamUnscheduleFromRunLoop(readStream,
							    readStreamRunLoop,
							    kCFRunLoopCommonModes);
	CFRelease(readStream);
	readStream = NULL;
	
	// end the thread's run loop
	CFRunLoopStop(readStreamRunLoop);//EXC_BAD_ACCESS 
	//first think: CFRunLoopRun should be called in a func such as setupReadStream, so when stop called  return control to the function that called CFRunLoopRun or CFRunLoopRunInMode for the current run loop activation. rather than called in a dispatch block
	//second think: CFRunLoopStop()  should be called in the current thread
	//most possibily: readStreamRunLoop is invalid
	dispatch_semaphore_signal(_semaphore); 
	
}

- (void) pushToMessagePool:(NSString *)line messageSendCompletion:(void (^)(bool))sendCompletion completion:(void (^)(bool))completion {
	
	MessageHandle *obj = [MessageHandle messageHandleWithMessage:line handle:sendCompletion];
	BOOL failed = dispatch_semaphore_wait(_semaphore, 10*NSEC_PER_SEC); //10秒
	[self.messagePool addObject:obj];
	dispatch_semaphore_signal(_semaphore);
	dispatch_async(dispatch_get_main_queue(), ^{
		completion(!failed);
	});
}

- (BOOL) sendLine:(NSString*)line /* completion:( void (^)(bool succeed/*, NSError *error) )completion*/ {
	
	line = [line stringByAppendingString:self.delimiter];
	//@autoreleasepool //GCD多线程不需要， GCD会管理内存
	//@synchronized (self) {
	//	dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
	//		if (!CFWriteStreamOpen(writeStream)) {
	//			//		CFStreamError myErr = CFWriteStreamGetError(*(writeStream));
	//			//		if (myErr.domain == kCFStreamErrorDomainPOSIX) {
	//			//			dispatch_async(dispatch_get_main_queue(), ^{
	//			//				completion(FALSE);
	//			//			});
	//			//		}
	//			dispatch_async(dispatch_get_main_queue(), ^{
	//				completion(FALSE);
	//			});
	//			return;
	//		}
	
	UInt8 *buf = [line cStringUsingEncoding:NSUTF8StringEncoding];
	CFIndex buflen = (CFIndex)strlen(buf);
	CFIndex nleft = buflen;
	while (nleft>0) {
		CFIndex bytesWritten = CFWriteStreamWrite(writeStream, buf, nleft);
		if (bytesWritten <= 0) {
			if (bytesWritten <= 0 && errno == EINTR) { //interrupted system call
				bytesWritten = 0;
			}
			else {
//				dispatch_async(dispatch_get_main_queue(), ^{
//					completion(FALSE);
//				});
				
				return FALSE;
			}
		}
		nleft -= bytesWritten;
		buf += bytesWritten;
	}
//	dispatch_async(dispatch_get_main_queue(), ^{
//		completion(TRUE);
//	});
	return TRUE;
	//		CFWriteStreamClose(writeStream);
	//	dispatch_semaphore_signal(semaphore);
	//}
	
}



- (void)dataReceived:(NSString *)data {
	NSLog(@"%@", data);
	if (buffer == nil) {
		buffer = [[NSMutableString alloc] initWithCapacity:128];

	}
	if (busyReceiving) {
		[buffer appendString:data];
		return;
	}
	@try {
		busyReceiving = TRUE;
		[buffer appendString:data];
		while ([buffer length] > 0 && !self.paused) {
			//NSArray *array = [buffer componentsSeparatedByString:_delimiter];
			NSRange lineRange = [buffer rangeOfString:_delimiter];
			if (lineRange.location == NSNotFound) {
				if ([buffer length] > self.maxLength) {
					/*
					NSRange wholeRange;
					wholeRange.location = 0;
					wholeRange.length = [buffer lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
					[buffer deleteCharactersInRange:wholeRange];
					 */
					[buffer setString:@""];
					return; //lineLengthExceeded(line);
				}
				return;
			}
			// get line
			NSString *line = [buffer substringToIndex:lineRange.location];
			//NSString *line = [buffer substringWithRange:lineRange];
			NSRange deleteRange = {0, lineRange.location+lineRange.length};
			[buffer deleteCharactersInRange:deleteRange];
			NSUInteger lineLength = [line length];
			if (lineLength > self.maxLength) {
				NSString *exceeded = [ [line stringByAppendingString:self.delimiter] stringByAppendingString:buffer];
				NSRange wholeRange;
				wholeRange.location = 0;
				wholeRange.length = [buffer lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
				[buffer deleteCharactersInRange:wholeRange];
				return; //lineLengthExceeded(exceeded);

			}
			[delegate lineReceived:line];
		}
	}
	@catch (NSException *exception) {
		NSLog(@"%@", exception);
	}
	@finally {
		busyReceiving = FALSE;
	}
	
	
}

- (void)didFinishReceivingData {
	while ([buffer length] > 0) {
		//NSArray *array = [buffer componentsSeparatedByString:_delimiter];
		NSRange lineRange = [buffer rangeOfString:_delimiter];
		if (lineRange.location == NSNotFound) {
			if ([buffer length] > self.maxLength) {
				NSString *line = [NSString stringWithString:buffer];
				//buffer = [[NSMutableString alloc] initWithCapacity:128];
				NSRange wholeRange;
				wholeRange.location = 0;
				wholeRange.length = [buffer lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
				[buffer deleteCharactersInRange:wholeRange];
				break; //lineLengthExceeded(line);
			}
			break;
		}
		// get line
		NSString *line = [buffer substringWithRange:lineRange];
		NSRange deleteRange = {0, lineRange.location+lineRange.length};
		[buffer deleteCharactersInRange:deleteRange];
		NSUInteger lineLength = [line length];
		if (lineLength > self.maxLength) {
			NSString *exceeded = [ [line stringByAppendingString:self.delimiter] stringByAppendingString:buffer];
			NSRange wholeRange;
			wholeRange.location = 0;
			wholeRange.length = [buffer lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
			[buffer deleteCharactersInRange:wholeRange];
			break; //lineLengthExceeded(exceeded);
			
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			[delegate lineReceived:line];
		});	
	}
		
	if ([self.delegate respondsToSelector:@selector(networkingResultsDidLoad:)]) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.delegate lineReceiverDisconnected];

		});
	}
}

@end
