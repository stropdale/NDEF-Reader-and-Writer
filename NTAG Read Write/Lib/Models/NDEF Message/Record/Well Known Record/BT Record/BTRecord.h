//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Record.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTRecord: Record

@property (assign) NSString * macAddress;
@property (assign) NSString * deviceName;
@property (assign) NSString * deviceClass;

- (id)initWithNDEFPayload:(NFCNDEFPayload *) NFCNDEFPayload;

@end

NS_ASSUME_NONNULL_END
