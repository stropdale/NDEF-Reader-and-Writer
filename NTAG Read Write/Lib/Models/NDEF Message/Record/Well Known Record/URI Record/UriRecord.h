//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Record.h"


@interface UriRecord: Record

@property (nonatomic,assign) NSString * uri;

- (id)initWithNDEFPayload:(NFCNDEFPayload *) NFCNDEFPayload;

- (NSString *) getUri;

@end

