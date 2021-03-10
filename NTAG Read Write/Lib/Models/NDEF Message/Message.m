//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "Message.h"
#import "Record.h"
#import "UriRecord.h"
#import "TextRecord.h"
#import "SmartPosterRecord.h"
#import "NtagUtils.h"

@implementation Message: NSObject

- (id)initWithNDEFMessage:(NFCNDEFMessage *) NDEFMessage{
    self = [super init];
    
    self.records = [[NSMutableArray alloc] init];
    
    for (int i=0; i < NDEFMessage.records.count; i++){
        Record * currentRecord = [[Record alloc]initWithNDEFPayload:NDEFMessage.records[i]];
        [self.records addObject:currentRecord];
    }
    
    return self;
}

- (Record *) getRecord: (int) position{
    return self.records[position];

}

-(int) getLen{
    return self.length;
}

-(int) getTimeInterval{
    return self.time_interval;
}

-(void) setLen: (int *) length{
    self.length = *(length);
}

-(void) setTimeInterval: (NSTimeInterval *) time_interval{
    self.time_interval = *(time_interval);
}

-(NFCNDEFMessage *) createMessageWithUriRecord: (NSString *) url appendPackage: (bool) appendPackage{
    
    NFCNDEFMessage * message;
    
    // Generate object NSUrl
    NSURL * nsurl = [[NSURL alloc] initWithString:url];
    
    // Init Payload
    NFCNDEFPayload * payload = [NFCNDEFPayload wellKnownTypeURIPayloadWithURL:nsurl];
    
    NSMutableArray<NFCNDEFPayload *> * records =  [[NSMutableArray alloc] init];
    
    [records addObject:payload];

    if (appendPackage){
              // Initialize properties to create NFCNDEFPayload object
              NFCTypeNameFormat nfcTypeFormatPackage = NFCTypeNameFormatNFCExternal;
              NSData * typePackage = [@"ios.com:pkg" dataUsingEncoding: NSASCIIStringEncoding];
              NSData * payloadPackage = [@"cmo.nxp.ntagi2cdemo" dataUsingEncoding: NSASCIIStringEncoding];
              NSData * identifierPackage = [[NSData alloc] init];
              
              // Create External Record Payload Object
              NFCNDEFPayload * payloadPkg = [[NFCNDEFPayload alloc] initWithFormat:nfcTypeFormatPackage type:payloadPackage identifier:identifierPackage payload:payloadPackage];
              
              [records addObject:payloadPkg];
          }
    
    // Generate NFCNDEFMessage object
    message = [[NFCNDEFMessage alloc] initWithNDEFRecords:records];
    
    return message;
}

-(NFCNDEFMessage *) createMessageWithTextRecord: (NSString *) text appendPackage: (bool) appendPackage{
    
    NFCNDEFMessage * message;
    
    // Calculate and compute the payload headers and fields
    char typeBytes [] = {0x54};
    char idBytes [] = {0x00};
    char payloadHeaderBytes [] = {0x02, 0x65, 0x6E};
    
    NSString * payloadHeader = [[NSString alloc] initWithBytes:payloadHeaderBytes length:sizeof(payloadHeaderBytes) encoding:(NSStringEncoding)NSASCIIStringEncoding];
    
    text = [NSString stringWithFormat:@"%@%@", payloadHeader, text];

    // Initialize properties to create NFCNDEFPayload object
    NFCTypeNameFormat nfcTypeFormat = NFCTypeNameFormatNFCWellKnown;
    NSData * type = [[NSData alloc]initWithBytes:typeBytes length:sizeof(typeBytes)];
    NSData * identifier = [[NSData alloc]initWithBytes:idBytes length:sizeof(idBytes)];
    NSData * payloadData = [text dataUsingEncoding: NSASCIIStringEncoding];
    
    NFCNDEFPayload * payload = [[NFCNDEFPayload alloc] initWithFormat:nfcTypeFormat type:type identifier:identifier payload:payloadData];
    
    NSMutableArray<NFCNDEFPayload *> * records =  [[NSMutableArray alloc] init];
    
    [records addObject:payload];
    
    if (appendPackage){
              // Initialize properties to create NFCNDEFPayload object
              NFCTypeNameFormat nfcTypeFormatPackage = NFCTypeNameFormatNFCExternal;
              NSData * typePackage = [@"ios.com:pkg" dataUsingEncoding: NSASCIIStringEncoding];
              NSData * payloadPackage = [@"cmo.nxp.ntagi2cdemo" dataUsingEncoding: NSASCIIStringEncoding];
              NSData * identifierPackage = [[NSData alloc] init];
              
              // Create External Record Payload Object
              NFCNDEFPayload * payloadPkg = [[NFCNDEFPayload alloc] initWithFormat:nfcTypeFormatPackage type:payloadPackage identifier:identifierPackage payload:payloadPackage];
              
              [records addObject:payloadPkg];
          }

    // Generate NFCNDEFMessage object
    message = [[NFCNDEFMessage alloc] initWithNDEFRecords:records];
    
    return message;
}

-(NFCNDEFMessage *) createMessageWithSPRecord: (NSString *) title uri: (NSString *) uri appendPackage: (bool) appendPackage{
    
    NFCNDEFMessage * message;
    uri  = [uri stringByReplacingOccurrencesOfString:@"http://www." withString:@""];

    // Calculate and compute the payload headers and fields
    char typeBytes [] = {0x53, 0x70};
    char idBytes [] = {0x00};
    int titleBytesNum = title.length + 3;
    int uriBytesNum = uri.length + 1;
    char titleHeaderBytes [] = {0x91, 0x01, titleBytesNum, 0x54, 0x02, 0x65, 0x6E};
    char uriHeaderBytes [] = {0x51, 0x01, uriBytesNum, 0x55, 0x01};
    
    NSData * titleData = [title dataUsingEncoding: NSASCIIStringEncoding];
    NSData * uriData = [uri dataUsingEncoding: NSASCIIStringEncoding];
    NSMutableData * titleHeaderData = [[NSMutableData alloc]initWithBytes:titleHeaderBytes length:sizeof(titleHeaderBytes)];
    NSMutableData * uriHeaderData = [[NSMutableData alloc]initWithBytes:uriHeaderBytes length:sizeof(uriHeaderBytes)];
    
    // Initialize properties to create NFCNDEFPayload object
    NFCTypeNameFormat nfcTypeFormat = NFCTypeNameFormatNFCWellKnown;
    NSData * type = [[NSData alloc]initWithBytes:typeBytes length:sizeof(typeBytes)];
    NSData * identifier = [[NSData alloc]initWithBytes:idBytes length:sizeof(idBytes)];
    NSMutableData * payloadData = [[NSMutableData alloc] init];

    [payloadData appendData:titleHeaderData];
    [payloadData appendData:titleData];
    [payloadData appendData:uriHeaderData];
    [payloadData appendData:uriData];
    
    NFCNDEFPayload * payload = [[NFCNDEFPayload alloc] initWithFormat:nfcTypeFormat type:type identifier:identifier payload:payloadData];
    
    NSMutableArray<NFCNDEFPayload *> * records =  [[NSMutableArray alloc] init];
    
    [records addObject:payload];
    
    if (appendPackage){
           // Initialize properties to create NFCNDEFPayload object
           NFCTypeNameFormat nfcTypeFormatPackage = NFCTypeNameFormatNFCExternal;
           NSData * typePackage = [@"ios.com:pkg" dataUsingEncoding: NSASCIIStringEncoding];
           NSData * payloadPackage = [@"cmo.nxp.ntagi2cdemo" dataUsingEncoding: NSASCIIStringEncoding];
           NSData * identifierPackage = [[NSData alloc] init];
           
           // Create External Record Payload Object
           NFCNDEFPayload * payloadPkg = [[NFCNDEFPayload alloc] initWithFormat:nfcTypeFormatPackage type:payloadPackage identifier:identifierPackage payload:payloadPackage];
           
           [records addObject:payloadPkg];
       }
    
    // Generate NFCNDEFMessage object
    message = [[NFCNDEFMessage alloc] initWithNDEFRecords:records];
    
    return message;
}

-(NFCNDEFMessage *) createMessageWithBTRecord: (NSString *) macAddress deviceName: (NSString *) deviceName deviceClass: (NSString *) deviceClass appendPackage: (bool) appendPackage{
    
    NFCNDEFMessage * message;
    
    // HANDOVER SELECT RECORD
    // Handover Select Record Parameters
    char HSRtypeBytes [] = {0x48, 0x73};
    char HSRidBytes [] = {0x00};
    char HSRData [] = {0x12, 0xd1, 0x02, 0x04, 0x61,0x63, 0x01, 0x01, 0x30, 0x00};

    // Initialize properties to create NFCNDEFPayload object for the Handover Select Record
    NFCTypeNameFormat HSRnfcTypeFormat = NFCTypeNameFormatNFCWellKnown;
    NSData * HSRtype = [[NSData alloc]initWithBytes:HSRtypeBytes length:sizeof(HSRtypeBytes)];
    NSData * HSRidentifier = [[NSData alloc]initWithBytes:HSRidBytes length:sizeof(HSRidBytes)];
    NSData * HSRPayloadData = [[NSData alloc]initWithBytes:HSRData length:sizeof(HSRidBytes)];

    NFCNDEFPayload * HSRpayload = [[NFCNDEFPayload alloc] initWithFormat:HSRnfcTypeFormat type:HSRtype identifier:HSRidentifier payload:HSRPayloadData];
    
    // MIME RECORD
    // Get bytes and compute headers
    char idBytesBT [] = {0x00};
    NSData * macAddressData = [NtagUtils dataFromHexString: macAddress];
    NSData * deviceNameData = [NtagUtils dataFromHexString: deviceName];
    NSData * deviceClassData = [NtagUtils dataFromHexString: deviceClass];
    
    char * macAddressHeaderBytes [] = {macAddressData.length, 0x00};
    char * deviceNameHeaderBytes [] = {deviceNameData.length + 1, 0x09};
    char * deviceClassHeaderBytes [] = {deviceClassData.length + 1, 0x0D};
    
    // Check correct lengths
    if(macAddressData.length != 6 || deviceNameData.length == 0 || deviceClassData.length != 3)
        return nil;
    
    // Build payload data structure
    NSMutableData * macAddressHeaderData = [[NSMutableData alloc]initWithBytes:macAddressHeaderBytes length:sizeof(macAddressHeaderBytes)];
    
    NSMutableData * deviceNameHeaderData = [[NSMutableData alloc]initWithBytes:deviceNameHeaderBytes length:sizeof(deviceNameHeaderBytes)];

    NSMutableData * deviceClassHeaderData = [[NSMutableData alloc]initWithBytes:deviceClassHeaderBytes length:sizeof(deviceClassHeaderBytes)];

    NSMutableData * payloadDataBT = [[NSMutableData alloc] init];

    [payloadDataBT appendData:macAddressHeaderData];
    [payloadDataBT appendData:macAddressData];
    [payloadDataBT appendData:deviceNameHeaderData];
    [payloadDataBT appendData:deviceNameData];
    [payloadDataBT appendData:deviceClassHeaderData];
    [payloadDataBT appendData:deviceClassData];
        
    // Initialize properties to create NFCNDEFPayload object
    NFCTypeNameFormat nfcTypeFormatBT = NFCTypeNameFormatMedia;
    NSData * typeBT = [@"application/vnd.bluetooth.ep.oob" dataUsingEncoding: NSASCIIStringEncoding];
    NSData * identifierBT = [[NSData alloc]initWithBytes:idBytesBT length:sizeof(idBytesBT)];
    
    // Create MIME Record Payload Object
     NFCNDEFPayload * payloadBT = [[NFCNDEFPayload alloc] initWithFormat:nfcTypeFormatBT type:typeBT identifier:identifierBT payload:payloadDataBT];
    
    
    // Append both Records
    NSMutableArray<NFCNDEFPayload *> * records = [[NSMutableArray alloc] init];
    
    [records addObject:HSRpayload];
    [records addObject:payloadBT];
    
    if (appendPackage){
        // Initialize properties to create NFCNDEFPayload object
        NFCTypeNameFormat nfcTypeFormatPackage = NFCTypeNameFormatNFCExternal;
        NSData * typePackage = [@"ios.com:pkg" dataUsingEncoding: NSASCIIStringEncoding];
        NSData * payloadPackage = [@"cmo.nxp.ntagi2cdemo" dataUsingEncoding: NSASCIIStringEncoding];
        NSData * identifierPackage = [[NSData alloc] init];
        
        // Create External Record Payload Object
        NFCNDEFPayload * payloadPkg = [[NFCNDEFPayload alloc] initWithFormat:nfcTypeFormatPackage type:payloadPackage identifier:identifierPackage payload:payloadPackage];
        
        [records addObject:payloadPkg];
    }
    
    // Generate NFCNDEFMessage object
    message = [[NFCNDEFMessage alloc] initWithNDEFRecords:records];
    
    return message;
    
}

@end

