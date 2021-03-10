//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "ExternalRecord.h"

@implementation ExternalRecord: Record

- (id)initWithNDEFPayload:(NFCNDEFPayload *) NFCNDEFPayload{
    
    self = [super init];
    
    self.type = [[NSString alloc] initWithData:NFCNDEFPayload.type encoding:NSASCIIStringEncoding];
    
    self.payload = [[NSString alloc] initWithData:NFCNDEFPayload.payload encoding:NSASCIIStringEncoding];
        
    return self;}

-(NSString *)getType{
    return self.type;
}

-(NSString *)getPayload{
    return self.payload;
}

@end
