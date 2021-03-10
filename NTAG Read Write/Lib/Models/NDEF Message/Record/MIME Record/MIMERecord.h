//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Record.h"

NS_ASSUME_NONNULL_BEGIN

@interface MIMERecord: Record

@property (nonatomic, copy) NSString * type;

- (id)initWithNDEFPayload:(NFCNDEFPayload *) NFCNDEFPayload;

-(NSString *)getType;

@end

NS_ASSUME_NONNULL_END
