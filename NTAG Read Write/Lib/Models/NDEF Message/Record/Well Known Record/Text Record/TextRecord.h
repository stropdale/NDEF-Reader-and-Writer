//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Record.h"

NS_ASSUME_NONNULL_BEGIN

@interface TextRecord: Record

@property (nonatomic, copy) NSString * text;

- (id)initWithNDEFPayload:(NFCNDEFPayload *) NFCNDEFPayload;

- (NSString *) getText;
@end

NS_ASSUME_NONNULL_END
