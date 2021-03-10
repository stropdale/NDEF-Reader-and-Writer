//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "MIMERecord.h"

@implementation MIMERecord: Record

- (id)initWithNDEFPayload:(NFCNDEFPayload *) NFCNDEFPayload{

    self = [super init];
    
    self.type = [[NSString alloc] initWithData:NFCNDEFPayload.type encoding:NSASCIIStringEncoding];
        
    return self;
}

-(NSString *)getType{
    return self.type;
}

@end
