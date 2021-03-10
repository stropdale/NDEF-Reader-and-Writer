//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "NtagUtils.h"

@implementation NtagUtils

#pragma mark - convertNSDataBytesToHexString
+ (NSMutableString *)convertNSDataBytesToHexString:(NSData * )response {
    NSData *data = response;
    NSUInteger capacity = data.length * 2;
    NSMutableString *sbuf = [NSMutableString stringWithCapacity:capacity];
    const unsigned char *buf = data.bytes;
    NSInteger i;
    for (i=0; i<data.length; ++i) {
        [sbuf appendFormat:@"%02lX", (unsigned long)buf[i]];
    }
    return sbuf;
}

#pragma mark - dataFromHexString
+ (NSData *)dataFromHexString:(NSString *) string {
    if([string length] % 2 == 1){
        string = [@"0"stringByAppendingString:string];
    }

    const char *chars = [string UTF8String];
    int i = 0, len = (int)[string length];

    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;

    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    return data;
}

@end
