//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreNFC/CoreNFC.h>
#import "Record.h"

NS_ASSUME_NONNULL_BEGIN

@interface Message: NSObject

@property(nonatomic, strong) NSMutableArray<Record *> * records;

@property(nonatomic, assign) int length;

@property(assign) NSTimeInterval time_interval;

- (id)initWithNDEFMessage:(NFCNDEFMessage *) NDEFMessage;

- (Record *) getRecord: (int) position;

-(int) getLen;

-(int) getTimeInterval;

-(void) setLen: (int *) length;

-(void) setTimeInterval: (NSTimeInterval *) time_interval;

-(NFCNDEFMessage *) createMessageWithUriRecord: (NSString *) url appendPackage: (bool) appendPackage;

-(NFCNDEFMessage *) createMessageWithTextRecord: (NSString *) text appendPackage: (bool) appendPackage;

-(NFCNDEFMessage *) createMessageWithSPRecord: (NSString *) title uri: (NSString *) uri appendPackage: (bool) appendPackage;

-(NFCNDEFMessage *) createMessageWithBTRecord: (NSString *) macAddress deviceName: (NSString *) deviceName deviceClass: (NSString *) deviceClass appendPackage: (bool) appendPackage;

@end

NS_ASSUME_NONNULL_END
