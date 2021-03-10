//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "NTAG_I2C_LIB.h"
#import "NtagUtils.h"
#import "Ntag_Get_Version.h"

@interface  NTAG_I2C_LIB()
@end

@implementation  NTAG_I2C_LIB

/* NFC Instances */
NFCTagReaderSession             * tagReader_session;
NSArray<__kindof id<NFCTag>>    * tags_saved;
NSObject <NFCMiFareTag>         * MIFareTag;

bool isSessionBegin   = FALSE;
bool checkCommandDone = false;

NSData * command_response;
NSData * answer_response;

int multiplier      = 0;
int times_to_split  = 0;
int isConnected     = 0;
int currentSector;

Ntag_Get_Version * product;

- (int) getSRAMSize{
    return 64;
}

#pragma mark - sharedInstance
+ ( NTAG_I2C_LIB *) sharedInstance{
    static  NTAG_I2C_LIB *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ sharedInstance = [[ NTAG_I2C_LIB alloc] init]; });
    return sharedInstance;
}

#pragma mark - initSession
- (void) initSession:(void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure{
    isConnected = 0;
    
    if(isSessionBegin){
        isSessionBegin = false;
        [tagReader_session restartPolling];
        [self close:^(NSData *aData) {} onFailure:^(NSError *error) {}];
    }
    
    tagReader_session = [[NFCTagReaderSession alloc] initWithPollingOption:NFCPollingISO14443
                                                                  delegate:self
                                                                     queue:dispatch_queue_create(NULL ,DISPATCH_QUEUE_CONCURRENT)];
    tagReader_session.alertMessage = MSG_NFC;
    [tagReader_session beginSession];
    isSessionBegin = TRUE;
}

#pragma mark - isConnect
- (int) isConnect{
    return isConnected;
}

#pragma mark - disconnect
- (void) close:(void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure{
    [tagReader_session setAlertMessage:@"Success!"];
    [tagReader_session invalidateSession];
    [tagReader_session restartPolling];
    isConnected = 0;
    
    [self ClearConnection];
}

#pragma mark - close with custom message
- (void) closeWithCustomMessage: (NSString *) alertMessage{
    [tagReader_session setAlertMessage:alertMessage];
    [tagReader_session invalidateSession];
    [tagReader_session restartPolling];
    isConnected = 0;
    
    [self ClearConnection];
}

#pragma mark - set alert message
- (void) setAlertMessage: (NSString *) alertMessage{
    [tagReader_session setAlertMessage:alertMessage];
}

- (void)ClearConnection {
    tagReader_session = nil;
    tags_saved = nil;
    MIFareTag = nil;
    isSessionBegin = false;
}

#pragma mark - errorMessage
- (void) errorMessage:(void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure{
    [tagReader_session invalidateSessionWithErrorMessage:@"Communication error"];
    isConnected = 1;
}

#pragma mark - Custom error message
- (void) customErrorMessage: (NSString *) message{
    [tagReader_session invalidateSessionWithErrorMessage:message];
    [tagReader_session invalidateSession];
    isConnected = 1;
}

#pragma mark - WriteSRAM
- (void) WriteSRAM:(NSMutableData  *)dataToProcess onSuccess:(void (^)(NSData *aData))success  onFailure : (void(^)(NSError *error))failure{
    int lom =(dataToProcess.length);
    times_to_split = lom / 64;  // 64 : 4 = 16
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, DELAY_WRITESRAM_CMDS * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        for (int i = 0; i < times_to_split; i++){
            
            NSData * dataToSend = [dataToProcess subdataWithRange:NSMakeRange(i*64, 64)];
            
            [self writeSRAMBlock:dataToSend onSuccess:^(NSData *aData) {
                
            } onFailure:^(NSError *error) {
                
            }];
            [NSThread sleepForTimeInterval:0.02f];
                             
        }
        
         [NSThread sleepForTimeInterval:0.1f];
        success(answer_response);
    });
}

#pragma mark - sendMIFARECommand
- (void) sendMIFARECommand:(NSData *) command onSuccess:(void (^)(NSData *aData))success  onFailure : (void(^)(NSError *error))failure{
    
    __block NSData *commandResponse = nil;
    NSString * commandStr = [NtagUtils convertNSDataBytesToHexString:command];
    
   [MIFareTag sendMiFareCommand:command completionHandler:^(NSData * _Nonnull response, NSError * _Nullable error) {
        
        if(response.description != nil){
            NSString * responseStr = [NtagUtils convertNSDataBytesToHexString:response];
            NSLog(@"MIFARE Command: %@ --> response: %@",commandStr, responseStr );
            commandResponse = response;
            success(response);
        }else{
            NSLog(@"ERROR in MIFARE Command: %@ --> error: %@",commandStr, error.description );
            failure(error);
            [self errorMessage:^(NSData *aData) {} onFailure:^(NSError *error) {}];
        }
    }];
}

#pragma mark - read NDEF
- (void) readNDEF:(void (^)(NFCNDEFMessage *NFCNDEFMessage) )success  onFailure : (void(^)(NSError *error))failure{
        
    [MIFareTag readNDEFWithCompletionHandler:^(NFCNDEFMessage * _Nullable NDEFMessage, NSError * _Nullable error) {
        
        if (NDEFMessage != nil){
            NSLog(@"read NDEF Message --> response: %@", NDEFMessage.description );
            success(NDEFMessage);
        } else {
            NSLog(@"ERROR in read NDEF Message --> error: %@", error.description );
            failure(error);
            [self errorMessage:^(NSData *aData) {} onFailure:^(NSError *error) {}];
        }
    }];
}

#pragma mark - write NDEF
- (void) writeNDEF: (NFCNDEFMessage *) NFCNDEFMessage onSuccess:(void (^)(void))success  onFailure : (void(^)(NSError *error))failure{
        
    [MIFareTag writeNDEF: NFCNDEFMessage completionHandler:^(NSError * _Nullable error) {
        
        if (error == nil){
            NSLog(@"Write NDEF Message success!");
            success();
        } else{
            NSLog(@"ERROR in write NDEF Message --> error: %@", error.description );
            [self errorMessage:^(NSData *aData) {} onFailure:^(NSError *error) {}];
            failure(error);
        }
        
    }];
}

#pragma mark - read
- (void) read: (NSInteger *)blockNr onSuccess:(void (^)(NSData *aData)) success  onFailure : (void(^)(NSError *error))failure{
        
        char command[] = {0x30, blockNr};
        NSData * cmd = [NSData dataWithBytes:command length:sizeof(command)];
        [self sendMIFARECommand:cmd onSuccess:^(NSData *aData) {
            success(aData);
        } onFailure:^(NSError *error) {
            
        }];
}

#pragma mark - fast read
- (void) fastRead: (int)startAddr endAddr: (int)endAddr onSuccess:(void (^)(NSData *aData)) success  onFailure : (void(^)(NSError *error))failure{
    
        char command[] = {0x3A, startAddr, endAddr};
        NSData * cmd = [NSData dataWithBytes:command length:sizeof(command)];
        [self sendMIFARECommand:cmd onSuccess:^(NSData *aData) {
            success(aData);
        } onFailure:^(NSError *error) {
            
        }];
}

#pragma mark - write
- (void) write: (NSInteger *)blockNr data: (NSData *) data onSuccess:(void (^)(NSData *aData)) success  onFailure : (void(^)(NSError *error))failure{
    
    const char * dataBytes = [data bytes];
    
    char command[6];
    command[0] = 0xA2;
    command[1] = blockNr;
    command[2] = dataBytes[0];
    command[3] = dataBytes[1];
    command[4] = dataBytes[2];
    command[5] = dataBytes[3];
    
    NSData * cmd = [NSData dataWithBytes:command length:sizeof(command)];
    [self sendMIFARECommand:cmd onSuccess:^(NSData *aData) {
        success(aData);
    } onFailure:^(NSError *error) {
        
    }];
}

#pragma mark - fast write
- (void) fastWrite: (NSData *) data startAddr: (int)startAddr endAddr: (int)endAddr onSuccess:(void (^)(NSData *aData)) success  onFailure : (void(^)(NSError *error))failure{
    
    char command[] = {0xA6, startAddr, endAddr};
    NSMutableData * cmd = [NSMutableData dataWithBytes:command length:sizeof(command)];
    [cmd appendData:data];
    
    [self sendMIFARECommand:cmd onSuccess:^(NSData *aData) {
        success(aData);
    } onFailure:^(NSError *error) {
        
    }];
}

#pragma mark - read SRAM Block
- (void) readSRAMBlock: (void (^)(NSData *aData)) success  onFailure : (void(^)(NSError *error))failure{
    
    int sram_selector = [product getSramSector];
    
    [self SectorSelect:sram_selector onSuccess:^(NSData *aData) {
        
    } onFailure:^(NSError *error) {
        failure(error);
    }];
    
    [self fastRead:0xF0 endAddr:0xFF onSuccess:^(NSData *aData) {
        success(aData);
    } onFailure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - SectorSelect
- (void) SectorSelect: (NSInteger *)sector onSuccess:(void (^)(NSData *aData)) success  onFailure : (void(^)(NSError *error))failure{
        
    if(currentSector == (int) sector){
        success(nil);
        return;
    }
    
    char command[] = {0xc2, 0xff};
    NSData * cmd = [NSData dataWithBytes:command length:sizeof(command)];
    [self sendMIFARECommand:cmd onSuccess:^(NSData *aData) {
        currentSector = sector;
        success(aData);
    } onFailure:^(NSError *error) {
        
    }];
    
    char sectorCommand[]  = {sector, 0x00, 0x00, 0x00};
    cmd = [NSData dataWithBytes:sectorCommand length:sizeof(sectorCommand)];
    [self sendMIFARECommand:cmd onSuccess:^(NSData *aData) {
        
    } onFailure:^(NSError *error) {
        
    }];
}

- (AuthStatus) obtainAuthStatus{
    return [self getProtectionPlus:^(NSData *aData) {
        
    } onFailure:^(NSError *error) {
        
    }];
}

#pragma mark - get Protection Plus
- (AuthStatus) getProtectionPlus:(void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure{
    
    __block AuthStatus status;
    __block NSData * accessData;
    
        [self SectorSelect:0 onSuccess:^(NSData *aData) {
    
        } onFailure:^(NSError *error) {
            return;
        }];
    
    [self read: 0xE3 onSuccess:^(NSData *aData) {
        const char * auth0Bytes = [aData bytes];
        
        if (aData.length <= 1)
            status = PROTECTED_RW_SRAM;
        else{
            if(auth0Bytes != NULL && sizeof(auth0Bytes) < 4){
                [self readSRAMBlock:^(NSData *aData) {
                    status = PROTECTED_RW;
                    
                } onFailure:^(NSError *error) {
                    
                }];
                
            } else {
                if((auth0Bytes[3] & 0xFF) <= 0xEB){
                    
                    [self read: 0xE4 onSuccess:^(NSData *aData) {
                        accessData = aData;
                        
                        [self read: 0xE7 onSuccess:^(NSData *aData) {
                            const char * pti2cBytes = [aData bytes];
                            const char * accessBytes = [accessData bytes];
                            
                            if ((((0x80 & accessBytes[0]) >> 0x07) == 1) &&
                                ((0x04 & pti2cBytes[0]) >> 0x02) == 1)
                                status = PROTECTED_RW_SRAM;
                            else if ((((0x80 & accessBytes[0]) >> 0x07) == 1) &&
                                     ((0x04 & pti2cBytes[0]) >> 0x02) == 0)
                                status = PROTECTED_RW;
                            else if ((((0x80 & accessBytes[0]) >> 0x07) == 0) &&
                                     ((0x04 & pti2cBytes[0]) >> 0x02) == 1)
                                status = PROTECTED_W_SRAM;
                            else if ((((0x80 & accessBytes[0]) >> 0x07) == 0) &&
                                     ((0x04 & pti2cBytes[0]) >> 0x02) == 0)
                                status = PROTECTED_W;
                        } onFailure:^(NSError *error) {
                            
                        }];
                        
                    } onFailure:^(NSError *error) {
                        
                    }];
                }
                status = UNPROTECTED;
            }
        }
    } onFailure:^(NSError *error) {
            
        }];
    
    [NSThread sleepForTimeInterval:0.1f];
    return status;
}

#pragma mark - protect Plus
- (void) protectPlus:(NSData *)pwd startAddr: (NSInteger *)startAddr onSuccess:(void (^)(NSData *aData)) success   onFailure : (void(^)(NSError *error))failure{
        
    [self SectorSelect:0 onSuccess:^(NSData *aData) {
        
    } onFailure:^(NSError *error) {
        return;
    }];
    
    // Set pwd indicated by the user
    [self write:0xE5 data:pwd onSuccess:^(NSData *aData) {
        
    } onFailure:^(NSError *error) {
        
    }];
    
    // Write access configuration
    char access [4] = {0x00, 0x00, 0x00, 0x00};
    access[0] ^= 1 << 0x07;
    access[0] ^= 0 << 0x05;
    access[0] |= 1 << 0x07;
    NSData * data = [[NSData alloc] initWithBytes:access length:sizeof(access)];
    
    [self write:0xE4 data:data onSuccess:^(NSData *aData) {
        
    } onFailure:^(NSError *error) {
        
    }];
    
    // Write access configuration
    char i2c_prot = 0x00;
    char pt_i2c [4] = {0x00, 0x00, 0x00, 0x00};
    pt_i2c[0] ^= 0 << 0x03;
    pt_i2c[0] ^= 1 << 0x02;
    pt_i2c[0] |= i2c_prot << 0x00;
    data = [[NSData alloc] initWithBytes:pt_i2c length:sizeof(access)];
    
    [self write:0xE7 data:data onSuccess:^(NSData *aData) {
        
    } onFailure:^(NSError *error) {
        
    }];
    
    // Write AUTH0 lock starting page
    char auth0 [4] = {0x00, 0x00, 0x00, startAddr};
    data = [[NSData alloc] initWithBytes:auth0 length:sizeof(access)];
    
    [self write:0xE3 data:data onSuccess:^(NSData *aData) {
        success(aData);
    } onFailure:^(NSError *error) {
        
    }];
}

#pragma mark - unprotect Plus
- (void) unprotectPlus:(void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure{
        
    [self SectorSelect:0 onSuccess:^(NSData *aData) {
        
    } onFailure:^(NSError *error) {
        return;
    }];
    
    char data_bytes [4] = {0x00, 0x00, 0x00, 0xFF};
    NSData * data = [[NSData alloc] initWithBytes:data_bytes length:sizeof(data_bytes)];
    
    [self write:0xE3 data:data onSuccess:^(NSData *aData) {
        
    } onFailure:^(NSError *error) {
        
    }];
    
    // Set Password to FFs
    char pdw_bytes [4] = {0xFF, 0xFF, 0xFF, 0xFF};
    data = [[NSData alloc] initWithBytes:pdw_bytes length:sizeof(pdw_bytes)];
    
    [self write:0xE5 data:data onSuccess:^(NSData *aData) {
        
    } onFailure:^(NSError *error) {
        
    }];
    
    // Write Access configuration
    char access_bytes [4] = {0x00, 0x00, 0x00, 0x00};
    data = [[NSData alloc] initWithBytes:access_bytes length:sizeof(access_bytes)];
    
    [self write:0xE4 data:data onSuccess:^(NSData *aData) {

    } onFailure:^(NSError *error) {
        
    }];
    
    // Write the PT I2C configuration
    [self write:0xE7 data:data onSuccess:^(NSData *aData) {
        success(aData);
    } onFailure:^(NSError *error) {
        
    }];
}

#pragma mark - get Version
- (void) getVersion:(void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure{
    
    char command[] = {0x60};
    NSData * data = [NSData dataWithBytes:command length:sizeof(command)];
    [self sendMIFARECommand:data onSuccess:^(NSData *aData) {
        success(aData);
    } onFailure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - get product
- (Prod) getProduct{
    
    __block Prod product;
    __block Ntag_Get_Version * version;
    
    [self getVersion:^(NSData *aData) {
        version = [[Ntag_Get_Version alloc] initWithData:aData];
        product = [version getProdType];
        
        if ([version getProdType] == UNKNOWN){
            [self read:0 onSuccess:^(NSData *aData) {
                unsigned char * bytes = [aData bytes];
                
                if(bytes[0] == 0x04 && bytes[12] == 0xE1 && bytes[13] == 0x10 && bytes[14] == 0x6D && bytes[15] == 0x00)
                    product = NTAG_I2C_1K;
                else if(bytes[0] == 0x04 && bytes[12] == 0xE1 && bytes[13] == 0x10 && bytes[14] == 0xEA && bytes[15] == 0x00)
                    product = NTAG_I2C_2K;
                
            } onFailure:^(NSError *error) {
                
            }];
        }
        
    } onFailure:^(NSError *error) {
        
    }];
    
    [NSThread sleepForTimeInterval:0.1f];
    return product;
}
 
#pragma mark - write default NDEF
- (void) writeDefaultNDEF:(void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure{
    
    char bytes[4];
    NSData * data;
    
    [self SectorSelect:0 onSuccess:^(NSData *aData) {
        
    } onFailure:^(NSError *error) {
        
    }];
    
    bytes[0] = 0x03;
    bytes[1] = 0x5F;
    bytes[2] = 0x91;
    bytes[3] = 0x02;
    data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    
    [self write:0x04 data:data onSuccess:^(NSData *aData) {
    } onFailure:^(NSError *error) {
    }];
    
    bytes[0] = 0x35;
    bytes[1] = 0x53;
    bytes[2] = 0x70;
    bytes[3] = 0x91;
    data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    
    [self write:0x05 data:data onSuccess:^(NSData *aData) {
    } onFailure:^(NSError *error) {
    }];
    
    bytes[0] = 0x01;
    bytes[1] = 0x14;
    bytes[2] = 0x54;
    bytes[3] = 0x02;
    data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    
    [self write:0x06 data:data onSuccess:^(NSData *aData) {
    } onFailure:^(NSError *error) {
    }];
    
    bytes[0] = 0x65;
    bytes[1] = 0x6E;
    bytes[2] = 0x4E;
    bytes[3] = 0x54;
    data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    
    [self write:0x07 data:data onSuccess:^(NSData *aData) {
    } onFailure:^(NSError *error) {
    }];
    
    bytes[0] = 0x41;
    bytes[1] = 0x47;
    bytes[2] = 0x20;
    bytes[3] = 0x49;
    data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    
    [self write:0x08 data:data onSuccess:^(NSData *aData) {
    } onFailure:^(NSError *error) {
    }];
    
    bytes[0] = 0x32;
    bytes[1] = 0x43;
    bytes[2] = 0x20;
    bytes[3] = 0x45;
    data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    
    [self write:0x09 data:data onSuccess:^(NSData *aData) {
    } onFailure:^(NSError *error) {
    }];
    
    bytes[0] = 0x58;
    bytes[1] = 0x50;
    bytes[2] = 0x4C;
    bytes[3] = 0x4F;
    data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    
    [self write:0x0A data:data onSuccess:^(NSData *aData) {
    } onFailure:^(NSError *error) {
    }];
   
   bytes[0] = 0x52;
   bytes[1] = 0x45;
   bytes[2] = 0x52;
   bytes[3] = 0x51;
   data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
   
   [self write:0x0B data:data onSuccess:^(NSData *aData) {
   } onFailure:^(NSError *error) {
   }];

    bytes[0] = 0x01;
    bytes[1] = 0x19;
    bytes[2] = 0x55;
    bytes[3] = 0x01;
    data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    
    [self write:0x0C data:data onSuccess:^(NSData *aData) {
    } onFailure:^(NSError *error) {
    }];
    
    bytes[0] = 0x6E;
    bytes[1] = 0x78;
    bytes[2] = 0x70;
    bytes[3] = 0x2E;
    data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    
    [self write:0x0D data:data onSuccess:^(NSData *aData) {
    } onFailure:^(NSError *error) {
    }];
    
    bytes[0] = 0x63;
    bytes[1] = 0x6F;
    bytes[2] = 0x6D;
    bytes[3] = 0x2F;
    data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    
    [self write:0x0E data:data onSuccess:^(NSData *aData) {
    } onFailure:^(NSError *error) {
    }];
    
    bytes[0] = 0x64;
    bytes[1] = 0x65;
    bytes[2] = 0x6D;
    bytes[3] = 0x6F;
    data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    
    [self write:0x0F data:data onSuccess:^(NSData *aData) {
    } onFailure:^(NSError *error) {
    }];
    
    bytes[0] = 0x62;
    bytes[1] = 0x6F;
    bytes[2] = 0x61;
    bytes[3] = 0x72;
    data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    
    [self write:0x10 data:data onSuccess:^(NSData *aData) {
    } onFailure:^(NSError *error) {
    }];
    
    bytes[0] = 0x64;
    bytes[1] = 0x2F;
    bytes[2] = 0x4F;
    bytes[3] = 0x4D;
    data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    
    [self write:0x11 data:data onSuccess:^(NSData *aData) {
    } onFailure:^(NSError *error) {
    }];
    
    bytes[0] = 0x35;
    bytes[1] = 0x35;
    bytes[2] = 0x36;
    bytes[3] = 0x39;
    data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    
    [self write:0x12 data:data onSuccess:^(NSData *aData) {
    } onFailure:^(NSError *error) {
    }];
    
    bytes[0] = 0x54;
    bytes[1] = 0x0F;
    bytes[2] = 0x13;
    bytes[3] = 0x61;
    data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    
    [self write:0x13 data:data onSuccess:^(NSData *aData) {
    } onFailure:^(NSError *error) {
    }];
    
    bytes[0] = 0x6E;
    bytes[1] = 0x64;
    bytes[2] = 0x72;
    bytes[3] = 0x6F;
    data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    
    [self write:0x14 data:data onSuccess:^(NSData *aData) {
    } onFailure:^(NSError *error) {
    }];
    
    bytes[0] = 0x69;
    bytes[1] = 0x64;
    bytes[2] = 0x2E;
    bytes[3] = 0x63;
    data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    
    [self write:0x15 data:data onSuccess:^(NSData *aData) {
    } onFailure:^(NSError *error) {
    }];
    
    bytes[0] = 0x6F;
    bytes[1] = 0x6D;
    bytes[2] = 0x3A;
    bytes[3] = 0x70;
    data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    
    [self write:0x16 data:data onSuccess:^(NSData *aData) {
    } onFailure:^(NSError *error) {
    }];
   
    bytes[0] = 0x6B;
    bytes[1] = 0x67;
    bytes[2] = 0x63;
    bytes[3] = 0x6F;
    data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    
    [self write:0x17 data:data onSuccess:^(NSData *aData) {
    } onFailure:^(NSError *error) {
    }];
    
     bytes[0] = 0x6D;
     bytes[1] = 0x2E;
     bytes[2] = 0x6E;
     bytes[3] = 0x78;
     data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
     
     [self write:0x18 data:data onSuccess:^(NSData *aData) {
     } onFailure:^(NSError *error) {
     }];
    
     bytes[0] = 0x70;
     bytes[1] = 0x2E;
     bytes[2] = 0x6E;
     bytes[3] = 0x74;
     data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
     
     [self write:0x19 data:data onSuccess:^(NSData *aData) {
     } onFailure:^(NSError *error) {
     }];
    
     bytes[0] = 0x61;
     bytes[1] = 0x67;
     bytes[2] = 0x69;
     bytes[3] = 0x32;
     data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
     
     [self write:0x1A data:data onSuccess:^(NSData *aData) {
     } onFailure:^(NSError *error) {
     }];
    
     bytes[0] = 0x63;
     bytes[1] = 0x64;
     bytes[2] = 0x65;
     bytes[3] = 0x6D;
     data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
     
     [self write:0x1B data:data onSuccess:^(NSData *aData) {
     } onFailure:^(NSError *error) {
     }];

    bytes[0] = 0x6F;
    bytes[1] = 0xFE;
    bytes[2] = 0x00;
    bytes[3] = 0x00;
    data = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
    
    [self write:0x1C data:data onSuccess:^(NSData *aData) {
        success(aData);
    } onFailure:^(NSError *error) {
    }];
}
    
#pragma mark - write EEPROM
- (void)
writeEEPROM: (NSData *) data onSuccess: (void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure{
    
    __block Prod product;
    __block Ntag_Get_Version * version;
    
    [self getVersion:^(NSData *aData) {
        version = [[Ntag_Get_Version alloc] initWithData:aData];
        product = [version getProdType];
        
        if(data.length > [version getMemsize]){
            NSError * error = [[NSError alloc] initWithDomain:@"" code:0 userInfo:@"Data is too long" ];
            failure (error);
        }
        
        [self SectorSelect:0 onSuccess:^(NSData *aData) {
        } onFailure:^(NSError *error) {
        }];
        
        NSInteger blockNr = 0x04;
        NSData * temp;
        int index = 0;
        
        // Write until data is written or block 0xFF was written (BlockNr should then be 0)
        for (index; index < data.length && blockNr != 0; index += 4){
            
            if (product == NTAG_I2C_2K_PLUS && blockNr == 0xE2)
                break;
            
            if (index + 4 >= data.length)
                temp = [data subdataWithRange:(NSRange){index,(data.length - index - 1)}];
            else
                temp = [data subdataWithRange:(NSRange){index,4}];
            
            [self write:blockNr data:temp onSuccess:^(NSData *aData) {
                
            } onFailure:^(NSError *error) {
                
            }];
            [NSThread sleepForTimeInterval:0.007f];
            blockNr++;
            
        }
        
        // In case data is left to write in sector 1
        if (index < data.length){
            [self SectorSelect:1 onSuccess:^(NSData *aData) {
                
            } onFailure:^(NSError *error) {
                
            }];
            
            blockNr = 0;
            for(;index < data.length; index += 4){
                
                temp = [data subdataWithRange:(NSRange){index, 4}];
                [self write:blockNr data:temp onSuccess:^(NSData *aData) {
                    
                } onFailure:^(NSError *error) {
                    
                }];
                [NSThread sleepForTimeInterval:0.007f];
                blockNr++;
                
            }
        }
        
        //[NSThread sleepForTimeInterval:0.1f];
        success(aData);
        
    } onFailure:^(NSError *error) {
        
    }];
}

#pragma mark - read EEPROM
- (void) readEEPROM: (int) absStart absEnd: (int) absEnd onSuccess: (void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure{
    
    __block NSMutableData * dataRead = [[NSMutableData alloc]init];
    __block Prod product;
    
    product = [self getProduct];
    
    [self SectorSelect:0 onSuccess:^(NSData *aData) {
       
    } onFailure:^(NSError *error) {
        
    }];
    
    NSInteger max_fast_read = 20;
    NSInteger fetch_start = absStart;
    NSInteger fetch_end = 0;

    while( fetch_start <= absEnd){
        [NSThread sleepForTimeInterval:0.008f];

        fetch_end = fetch_start + max_fast_read - 1;

        if(fetch_end > absEnd)
            fetch_end = absEnd;

        if(product != NTAG_I2C_2K_PLUS){
            if ((fetch_start & 0xFF00) != (fetch_end & 0xFF00))
                fetch_end = (fetch_start & 0xFF00) + 0xFF;
        } else {
            if ((fetch_start & 0xFF00) == 0 && (fetch_end > 0xE2))
                fetch_end = (fetch_start & 0xFF00) + 0xE1;
        }

        [self fastRead:(fetch_start & 0x00FF)endAddr:(fetch_end & 0x00FF) onSuccess:^(NSData *aData) {

            [dataRead appendData:aData];

        } onFailure:^(NSError *error) {

        }];

        fetch_start = fetch_end + 1;

        if(product != NTAG_I2C_2K_PLUS){
            if ((fetch_start & 0xFF00) != (fetch_end & 0xFF00)){
                [self SectorSelect:1 onSuccess:^(NSData *aData) {

                } onFailure:^(NSError *error) {

                }];
            }
        } else {
            if ((fetch_start & 0xFF00) == 0 && (fetch_end >= 0xE1)){
                //break;
                [self SectorSelect:1 onSuccess:^(NSData *aData) {

                } onFailure:^(NSError *error) {

                }];

                fetch_start = 0x100;
                absEnd = absEnd + (0xFF - 0xE2);
            }
        }
    }

    [NSThread sleepForTimeInterval:0.007f];
    
    [self SectorSelect:0 onSuccess:^(NSData *aData) {
        success(dataRead);

    } onFailure:^(NSError *error) {

    }];
}

#pragma mark - get Session Registers
- (void) getSessionRegisters:(void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure{
    Prod product = [self getProduct];
    int sector = 3;
    int blockNr = 0xF8;
    
    if (product == NTAG_I2C_1K_PLUS || product == NTAG_I2C_2K_PLUS){
        sector = 0;
        blockNr = 0xEC;
    }
    
    [self SectorSelect:sector onSuccess:^(NSData *aData) {
        
    } onFailure:^(NSError *error) {

    }];
    
    [self read:blockNr onSuccess:^(NSData *aData) {
        success(aData);
    } onFailure:^(NSError *error) {
        
    }];
}

#pragma mark - get Session Register
- (void) getSessionRegister: (SR_Offset) offset onSuccess: (void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure{
    
    [self getSessionRegisters:^(NSData *aData) {
        [aData subdataWithRange:NSMakeRange(offset, 1)];
        success(aData);
    } onFailure:^(NSError *error) {
        
    }];
}

#pragma mark - checkPTwritePossible
- (Boolean) checkPTwritePossible {
    
    __block isPTwritePossible = true;
    
    [self getSessionRegister:NC_REG onSuccess:^(NSData *aData) {
        unsigned char * bytes = [aData bytes];
        if (bytes[0] & ((0x01 << 6) == 0) || (bytes[0] & (0x01 << 0)) == 0 )
            checkCommandDone = false;
        
    } onFailure:^(NSError *error) {
        checkCommandDone = false;
    }];
    
    [self getSessionRegister:NS_REG onSuccess:^(NSData *aData) {
        unsigned char * bytes = [aData bytes];
        if (bytes[0] & ((0x01 << 5) == 0))
            checkCommandDone = false;
        
    } onFailure:^(NSError *error) {
        checkCommandDone = false;
    }];
    
    [NSThread sleepForTimeInterval:0.1f];
    
    return isPTwritePossible;
}

#pragma mark - write SRAM Block
- (void) writeSRAMBlock: (NSData *) data onSuccess: (void (^)(NSData *aData)) success  onFailure : (void(^)(NSError *error))failure{
    
    unsigned char TxBuffer[4];
    int index = 0;
    
    int sram_selector = [product getSramSector];
    [self SectorSelect:sram_selector onSuccess:^(NSData *aData) {
        
    } onFailure:^(NSError *error) {
        
    }];
    
    __block Prod product;
    __block Ntag_Get_Version * version;
    
    [self getVersion:^(NSData *aData) {
        version = [[Ntag_Get_Version alloc] initWithData:aData];
        product = [version getProdType];
    } onFailure:^(NSError *error) {
        
    }];
    
    [NSThread sleepForTimeInterval:0.1f];
    
    if(product == NTAG_I2C_1K_PLUS || product == NTAG_I2C_2K_PLUS){
        [[NTAG_I2C_LIB sharedInstance] fastWrite:data startAddr:0xF0 endAddr:0xF0 + 0x0F onSuccess:^(NSData *aData) {
            success(aData);
        } onFailure:^(NSError *error) {
            
        }];
    } else {
        for (int i = 0; i < 16; i++){
            for (int d_i = 0; d_i < 4; d_i++){
                if (index < data.length)
                    TxBuffer[d_i] = [[data subdataWithRange:NSMakeRange(index++, 1)] bytes];
                else
                    TxBuffer[d_i] = 0x00;
            }
            NSData * dataToWrite = [[NSData alloc] initWithBytes:TxBuffer length:sizeof(TxBuffer)];
            
            [[NTAG_I2C_LIB sharedInstance] write:0xF0 + i data:dataToWrite onSuccess:^(NSData *aData) {
                if (i == 15)
                    success(aData);
            } onFailure:^(NSError *error) {
                return;
            }];
        
        }
    }
    
}

#pragma mark - tagReaderSession
- (void) tagReaderSession:(NFCTagReaderSession *)session didDetectTags:(nonnull NSArray<__kindof id<NFCTag>> *)tags
{
    tags_saved = tags;
    
    NSLog(@"-->Tag Detected on Field");
   
    NSObject <NFCTag> * nfcTagObject = tags.firstObject;
    NSLog(@"-->MIFARE Tag Identifier:%@", nfcTagObject.asNFCMiFareTag.identifier);
    NSLog(@"-->MIFARE Tag Family:%lu", (unsigned long)nfcTagObject.asNFCMiFareTag.mifareFamily);
    NSLog(@"-->MIFARE Tag Historial Bytes:%lu", (unsigned long)nfcTagObject.asNFCMiFareTag.historicalBytes);
    NSLog(@"-->MIFARE Tag Type :%lu", (unsigned long)nfcTagObject.asNFCMiFareTag.type);
    NSLog(@"-->MIFARE Tag description: %@", (unsigned long)nfcTagObject.asNFCMiFareTag.description);
    
    connectToTag(nfcTagObject);
}

#pragma mark - connectToTag
static void connectToTag(NSObject<NFCTag> *nfcTagObject) {
    MIFareTag = nfcTagObject.asNFCMiFareTag;
    NSLog(@"-->Connecting to Tag!");
    [tagReader_session connectToTag:MIFareTag completionHandler:^(NSError * _Nullable error) {
        if(error != nil){
            NSLog(@"%@", error.description);
            isConnected = 4;
            return;
        }else{
            NSLog(@"-->Connected!");
            isConnected = 3;
        }
        
        NSLog(@"-->Is MIFARE tag Available?");
        if(MIFareTag.isAvailable){
            NSLog(@"-->Yes, It is!");
        }
    
        MIFareTag = MIFareTag;
    }];
}

#pragma mark - tagReaderSession
-(void) tagReaderSession:(NFCTagReaderSession *)session didInvalidateWithError:(NSError *)error
{
    isConnected = 0;

    NSLog(@"Tag Reader Session Status: Invalidated,  %@", error.description);
    
    isSessionBegin = false;
    
    [tagReader_session restartPolling];
    
    [self close:^(NSData *aData) {
    } onFailure:^(NSError *error) {
        [tagReader_session invalidateSessionWithErrorMessage:@"Communication error"];
    }];
}

#pragma mark - tagReaderSessionDidBecomeActive
-(void)tagReaderSessionDidBecomeActive:(NFCTagReaderSession *)session{
     NSLog(@"Tag Reader Session Did Become Active response: %@", session.description);
}


@end
