//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "SmartPosterRecord.h"
#import "Record.h"

@implementation SmartPosterRecord: Record


- (id)initWithNDEFPayload:(NFCNDEFPayload *) NFCNDEFPayload{

    self = [super init];
    
    const char * payloadBytes = NFCNDEFPayload.payload.bytes;
    
    // Extracting lenth and initial positions of title and URI from headers
    NSInteger headerLen = 5;
    NSInteger titleStartPos = headerLen + 2;
    NSInteger titleLen = payloadBytes[2] - 3;
    NSInteger uriStartPos = headerLen + titleLen + headerLen + 2;
    NSInteger uriLen = payloadBytes[uriStartPos - 3] -1;
    
    UInt8 *titleBytes = (UInt8 *)[NFCNDEFPayload.payload subdataWithRange:(NSRange){titleStartPos,titleLen}].bytes;
    
    UInt8 *uriBytes = (UInt8 *)[NFCNDEFPayload.payload subdataWithRange:(NSRange){uriStartPos,uriLen}].bytes;
    
    self.title = [[NSString alloc]initWithBytes:titleBytes length:titleLen encoding:NSASCIIStringEncoding];
    
    self.uri = [[NSString alloc]initWithBytes:uriBytes length:uriLen encoding:NSASCIIStringEncoding];

       return self;
}

- (NSString *) getUri{
    return self.uri;
}

- (NSString *) getTitle{
    return self.title;
}

- (NSString *) getId{
    return self.id;
}

@end
