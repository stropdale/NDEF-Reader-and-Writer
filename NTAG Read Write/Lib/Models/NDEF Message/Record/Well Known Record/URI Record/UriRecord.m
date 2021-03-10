//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "UriRecord.h"
#import "Record.h"

@implementation UriRecord: Record

- (id)initWithNDEFPayload:(NFCNDEFPayload *) NFCNDEFPayload{
    self = [super init];
    
    self.uri = NFCNDEFPayload.wellKnownTypeURIPayload;
    
    return self;
}

- (NSString *) getUri{
    return self.uri;
}

@end
