//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "Record.h"
#import "UriRecord.h"
#import "TextRecord.h"
#import "SmartPosterRecord.h"
#import "BTRecord.h"
#import "MIMERecord.h"
#import "ExternalRecord.h"

@implementation Record: NSObject

- (id)initWithNDEFPayload: (NFCNDEFPayload *) NFCNDEFPayload{
    self = [super init];
    
    id record = nil;
    
    switch (NFCNDEFPayload.typeNameFormat) {
            
        case 1:
            // Parse Well Known Record
            record = [self parseWellKnownRecord:NFCNDEFPayload];
            break;
            
        case 2:
            // MIME Record
            record = [[MIMERecord alloc]initWithNDEFPayload:NFCNDEFPayload];
            break;
            
        case 4:
            // External Record
            record = [[ExternalRecord alloc]initWithNDEFPayload:NFCNDEFPayload];
            break;
            
        case 5:
            // Unknown Record
            self.recordType = UNKNOWN_RECORD;
            break;
            
        default:
            break;
    }
    
    return record;
}

- (id)parseWellKnownRecord:(NFCNDEFPayload *) NFCNDEFPayload{
    const char * typeBytes = [NFCNDEFPayload.type bytes];
    
    id record = nil;
    
    if(NFCNDEFPayload.type.length == 1){
        switch (typeBytes[0]) {
            case 84:
                record = [[TextRecord alloc]initWithNDEFPayload:NFCNDEFPayload];
                break;
            case 85:
                record = [[UriRecord alloc]initWithNDEFPayload:NFCNDEFPayload];
                break;
            default:
                break;
        }
    } else if(NFCNDEFPayload.type.length == 2){
        switch (typeBytes[0]) {
            case 83:
                if (typeBytes[1] == 112){
                    record = [[SmartPosterRecord alloc]initWithNDEFPayload:NFCNDEFPayload];
                }
                break;
            case 72:
                record = [[BTRecord alloc]initWithNDEFPayload:NFCNDEFPayload];                break;
            default:
                break;
        }
    }
    return record;
}

- (RecordType) getRecordType{
    if ([self class] == [ SmartPosterRecord class])
        return SP_RECORD;
    else if ([self class] == [ TextRecord class])
        return TEXT_RECORD;
    else if ([self class] == [ UriRecord class])
        return URI_RECORD;
    else if ([self class] == [ BTRecord class])
        return BT_RECORD;
    else if ([self class] == [ MIMERecord class])
        return MIME_RECORD;
    else if ([self class] == [ ExternalRecord class])
        return EXTERNAL_RECORD;
    else
        return UNKNOWN_RECORD;
}
@end
