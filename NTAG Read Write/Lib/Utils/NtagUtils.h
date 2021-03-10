//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NtagUtils : NSObject

/*!
@abstract  This method performs the convertion of the NSData Bytes to a Hex String Array
 @param response the  data to be processed
*/
+ (NSMutableString *)convertNSDataBytesToHexString:(NSData * )response;

/*!
@abstract  This method performs the convertion of the Hex String Array to an NSData of bytes
 @param string the  data to be processed
*/
+ (NSData *)dataFromHexString:(NSString *) string;

@end
