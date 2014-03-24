/**
    Copyright (C) 2013 Eric Wasylishen

    Date:  November 2013
    License:  MIT  (see COPYING)
 */

#import <CoreObject/CoreObject.h>

@class COSynchronizerJSONServer;

@protocol COSynchronizerJSONServerDelegate <NSObject>

- (void) JSONServer: (COSynchronizerJSONServer *)server sendText: (NSString *)text toClient: (NSString *)client;

@end

@interface COSynchronizerJSONServer : NSObject <COSynchronizerServerDelegate>
{
	NSMutableDictionary *queuedOutgoingMessagesByClient;
	NSMutableArray *queuedIncomingMessages;
	BOOL paused;
}

@property (nonatomic, readwrite, strong) id<COSynchronizerJSONServerDelegate> delegate;
@property (nonatomic, readwrite, weak) COSynchronizerServer *server;

- (void) receiveText: (NSString *)text fromClient: (NSString *)aClient;

@property (nonatomic, readwrite, assign) BOOL paused;

@end
