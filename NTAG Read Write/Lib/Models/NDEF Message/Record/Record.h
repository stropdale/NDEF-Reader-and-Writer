//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreNFC/CoreNFC.h>

NS_ASSUME_NONNULL_BEGIN

@interface Record: NSObject

typedef enum RecordTypes
{
    TEXT_RECORD,
    URI_RECORD,
    BT_RECORD,
    SP_RECORD,
    MIME_RECORD,
    EXTERNAL_RECORD,
    UNKNOWN_RECORD
} RecordType;

@property (assign) RecordType recordType;

- (id)initWithNDEFPayload:(NFCNDEFPayload *) NFCNDEFPayload;

- (id)parseWellKnownRecord:(NFCNDEFPayload *) NFCNDEFPayload;

- (RecordType) getRecordType;

@end

NS_ASSUME_NONNULL_END
