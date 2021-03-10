//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreNFC/CoreNFC.h>
#import "Ntag_Get_Version.h"
#import "Constants.h"
#import "NtagUtils.h"



@interface  NTAG_I2C_LIB : NSObject <NFCNDEFReaderSessionDelegate, NFCTagReaderSessionDelegate, NFCMiFareTag>

typedef enum AuthStatusTypes
{
    DISABLED,
    UNPROTECTED,
    AUTHENTICATED,
    PROTECTED_W,
    PROTECTED_RW,
    PROTECTED_W_SRAM,
    PROTECTED_RW_SRAM
} AuthStatus;

typedef enum SR_OffsetTypes
{
    NC_REG = 0x00,
    LAST_NDEF_PAGE = 0x01,
    SM_REG = 0x02,
    WDT_LS = 0x03,
    WDT_MS = 0x04,
    I2C_CLOCK_STR = 0x05,
    NS_REG = 0x06,
    FIXED = 0x07
} SR_Offset;

typedef enum NC_Reg_FuncTypes
{
    PTHRU_DIR = (0x01 << 0),
    SRAM_MIRROR_ON_OFF = (0x01 << 1),
    FD_ON = (0x03 << 2),
    FD_OFF = (0x03 << 4),
    PTHRU_ON_OFF = (0x01 << 6),
    I2C_RST_ON_OFF = (0x01 << 7)
} NC_Reg_Func;

typedef enum NS_Reg_FuncTypes
{
    RF_FIELD_PRESENT = (0x01 << 0),
    EEPROM_WR_BUSY = (0x01 << 1),
    EEPROM_WR_ERR = (0x01 << 2),
    SRAM_RF_READY = (0x01 << 3),
    SRAM_I2C_READY = (0x01 << 4),
    RF_LOCKED = (0x01 << 5),
    I2C_LOCKED = (0x01 << 6),
    NDEF_DATA_READ = (0x01 << 7)
} NS_Reg_Func;

typedef enum Access_OffsetTypes
{
    NFC_PROT = 0x07,
    NFC_DIS_SEC1 = 0x05,
    AUTH_Lim = 0x00
} Access_Offset;

typedef enum PTI_I2C_OffsetTypes
{
    K2_PROT = 0x03,
    SRAM_PROT = 0x02,
    I2C_PROT = 0x00
} PTI_I2C_Offset;



- (int) getSRAMSize;

+ ( NTAG_I2C_LIB *) sharedInstance;

/*!
@abstract  Inits an NFC Session
 */
- (void) initSession:(void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure;

/*!
@abstract  return the NFC connection state
 */
- (int) isConnect;

/*!
@abstract  closes the NFC sessions¡with a Successful message
 */
- (void) close:(void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure;

/*!
@abstract  Closes the NFCs ession with a custom error message
@param alertMessage is the error message to be displayed
 */
- (void) closeWithCustomMessage: (NSString *) alertMessage;

/*!
@abstract  Sets the NFC alert message in the NFC interface
@param alertMessage is the  message to be displayed
 */
- (void) setAlertMessage: (NSString *) alertMessage;

/*!
@abstract  Closes the NFCs ession with an error
 */
- (void) errorMessage:(void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure;

/*!
@abstract  Closes the NFCs ession with an error message and a custom alert message
@param message is the error message to be displayed
 */
- (void) customErrorMessage: (NSString *) message;

/*!
@abstract  Writes data t the SRAM of the NTAG I2C
@param dataToProcess is the data to be written in the SRAM
 */
- (void) WriteSRAM:(NSMutableData  *)dataToProcess onSuccess:(void (^)(NSData *aData))success  onFailure : (void(^)(NSError *error))failure;

/*!
@abstract  Sends a custom MIFARE command to the NTAG I2C
@param command is the command data values to be sent
 */
- (void) sendMIFARECommand:(NSData *) command onSuccess:(void (^)(NSData *aData))success  onFailure : (void(^)(NSError *error))failure;

/*!
@abstract  Reads an NDEF message from the NTAG I2C
 */
- (void) readNDEF:(void (^)(NFCNDEFMessage *NFCNDEFMessage) )success  onFailure : (void(^)(NSError *error))failure;

/*!
@abstract  Writes an NDEF message to the NTAG I2C
 */
- (void) writeNDEF: (NFCNDEFMessage *) NFCNDEFMessage onSuccess:(void (^)(void))success  onFailure : (void(^)(NSError *error))failure;


/*!
@abstract  reads a memory block from the NTAG I2C
@param blockNr address of the block to be read
 */
- (void) read: (NSInteger *)blockNr onSuccess:(void (^)(NSData *aData)) success  onFailure : (void(^)(NSError *error))failure;

/*!
@abstract  performs a fast read operation
@param startAddr is the starting block address to read from
@param endAddr last address to read in the fastRead process
*/
- (void) fastRead: (int)startAddr endAddr: (int)endAddr onSuccess:(void (^)(NSData *aData)) success  onFailure : (void(^)(NSError *error))failure;

/*!
@abstract  writes data to a memory block in the NTAG I2C
@param data data to be written
@param blockNr  block address to write to
*/
- (void) write: (NSInteger *)blockNr data: (NSData *) data onSuccess:(void (^)(NSData *aData)) success  onFailure : (void(^)(NSError *error))failure;

/*!
@abstract  performs a fast write operation
@param startAddr is the starting block address to write to
@param endAddr last address to write in the fastWrite process
*/
- (void) fastWrite: (NSData *) data startAddr: (int)startAddr endAddr: (int)endAddr onSuccess:(void (^)(NSData *aData)) success  onFailure : (void(^)(NSError *error))failure;

/*!
@abstract  Reads the SRAM Block content
*/
- (void) readSRAMBlock: (void (^)(NSData *aData)) success  onFailure : (void(^)(NSError *error))failure;

/*!
@abstract  selects the desire sector in the NTAG I2C
@param sector is the sector to select
*/
- (void) SectorSelect: (NSInteger *)sector onSuccess:(void (^)(NSData *aData)) success  onFailure : (void(^)(NSError *error))failure;

/*!
@abstract  returns the authentication status of the NTAG I2C
*/
- (AuthStatus) obtainAuthStatus;


/*!
@abstract  gets the protection  parameters of the NTAG I2C plus
*/
- (AuthStatus) getProtectionPlus:(void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure;


/*!
 @abstract  protects the NTAG I2C plus with a password
 @param pwd is the password to set
 @param startAddr is teh starting addres to set in the AUTH0 Register
*/
- (void) protectPlus:(NSData *)pwd startAddr: (NSInteger *)startAddr onSuccess:(void (^)(NSData *aData)) success   onFailure : (void(^)(NSError *error))failure;

/*!
 @abstract  unprotects the NTAG I2C plus
*/
- (void) unprotectPlus:(void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure;

/*!
 @abstract  retrieves the version information
*/
- (void) getVersion:(void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure;

/*!
 @abstract  Returns the product type of the NTAG
*/
- (Prod) getProduct;

 /*!
  @abstract Writes the default NDEF to the NTAG I2C
 */
- (void) writeDefaultNDEF:(void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure;

/*!
 @abstract  writes data to the EEPROM
 @param data is the data to be written
*/
- (void) writeEEPROM: (NSData *) data onSuccess: (void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure;

/*!
 @abstract  Reads the EEPROM content
 @param absStart is the starting block address to read from
 @param absEnd is the last block address to read
*/
- (void) readEEPROM: (int) absStart absEnd: (int) absEnd onSuccess: (void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure;

/*!
 @abstract  Returns the session register data
*/
- (void) getSessionRegisters:(void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure;

/*!
 @abstract  Returns a specific register from the session registers
*/
- (void) getSessionRegister: (SR_Offset) offset onSuccess: (void (^)(NSData *aData) )success  onFailure : (void(^)(NSError *error))failure;

/*!
 @abstract  Checks the PT status to see if the tag can be written
*/
- (Boolean) checkPTwritePossible;

/*!
 @abstract  Writes to the SRAM
 @param data is the data to be written
*/
- (void) writeSRAMBlock: (NSData *) data onSuccess: (void (^)(NSData *aData)) success  onFailure : (void(^)(NSError *error))failure;

- (void) tagReaderSession:(NFCTagReaderSession *)session didDetectTags:(nonnull NSArray<__kindof id<NFCTag>> *)tags;

static void connectToTag(NSObject<NFCTag> *nfcTagObject);

-(void) tagReaderSession:(NFCTagReaderSession *)session didInvalidateWithError:(NSError *)error;

-(void)tagReaderSessionDidBecomeActive:(NFCTagReaderSession *)session;

@end
