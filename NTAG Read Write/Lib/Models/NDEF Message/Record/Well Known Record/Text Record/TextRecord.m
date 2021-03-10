//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "TextRecord.h"
#import "Record.h"

@implementation TextRecord: Record

- (id)initWithNDEFPayload:(NFCNDEFPayload *) NFCNDEFPayload{
    self = [super init];
    
    const char * payloadBytes = NFCNDEFPayload.payload.bytes;
    
    // Obtain start position and length of text from header
    NSUInteger textStartPos = payloadBytes[0] + 1;
    NSUInteger textLen = NFCNDEFPayload.payload.length - payloadBytes[0] - 1;

    UInt8 *textBytes = (UInt8 *)[NFCNDEFPayload.payload subdataWithRange:(NSRange){textStartPos,textLen}].bytes;
    
    self.text = [[NSString alloc]initWithBytes:textBytes length:textLen encoding:NSASCIIStringEncoding];
    
    NSLog(@"TEXT RECORD: %@",self.text);
    return self;
}

- (NSString *) getText{
    return self.text;
}
@end
