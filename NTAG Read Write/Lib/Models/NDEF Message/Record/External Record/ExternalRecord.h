//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Record.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExternalRecord: Record

@property (nonatomic, copy) NSString * type;

@property (nonatomic, copy) NSString * payload;

- (id)initWithNDEFPayload:(NFCNDEFPayload *) NFCNDEFPayload;

-(NSString *)getType;

-(NSString *)getPayload;

@end

NS_ASSUME_NONNULL_END
