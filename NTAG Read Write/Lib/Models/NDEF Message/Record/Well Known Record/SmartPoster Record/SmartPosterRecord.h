//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Record.h"

NS_ASSUME_NONNULL_BEGIN

@interface SmartPosterRecord: Record

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * uri;
@property (nonatomic, copy) NSString * id;

- (id)initWithNDEFPayload:(NFCNDEFPayload *) NFCNDEFPayload;

- (NSString *) getUri;

- (NSString *) getTitle;

- (NSString *) getId;

@end

NS_ASSUME_NONNULL_END
