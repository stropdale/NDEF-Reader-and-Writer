//  Copyright 2019 mobileknowledge. All rights reserved.
//

#define DELAY_BETWEEN_CMDS       0.1
#define DELAY_BETWEEN_FAST_CMDS  0.075

#define DELAY_WRITESRAM_CMDS     0.075

#define POS_INIT_SRAM            240

#define MSG_NFC                  @"Hold your phone near the tag to begin"

#define WRITE_SRAM_CMD           @"0xA2"
#define FAST_WRITE_CMD           @"0xA6"

#define WRITE_CMD                @"0xA2"
#define FAST_READ_CMD            @"0x3A"

#define READ_CMD                 @"0x30"

#define SECTOR_SELECT_1_CMD      @"0xC2"
#define SECTOR_SELECT_2_CMD      @"0xFF"

#define GET_VERSION_CMD          @"0x60"

#define SECTOR_ZERO              @"0x00"
#define SECTOR_ONE               @"0x01"

#define PROTECTION_PLUS_CMD      @"0xE3"
#define CHECK_PT_WRITE_CMD       @"0xEC"

#define EMPTY_CMD                @"0x00"

#define START_ADDRESS            @"0xF0"
#define END_ADDRESS              @"0xFF"

#define AUTH_PLUS_CMD            @"0x1B"

//Speed Use Case
#define FAST_MODE                0
#define POLLING_MODE             1
#define ERROR_MODE               2

#define str_fast_mode            @"Fast Mode"
#define str_polling_mode         @"Polling Mode"

#define APP_VERSION              @"1.7.8"
#define DATA_SEND_BYTE           12
#define VERSION_BYTE             63
#define LAST_FOUR_BYTES          4
#define THREE_BYTES              3
#define GET_VERSION_NR           12
#define GET_FW_NR                28

#define PAGE_SIZE                4096

#define URL_WEB_LINK_WEBPAGE     @"https://www.nxp.com/products/rfid-nfc/nfc-hf/ntag/nfc-tags-for-electronics/ntag-ic-iplus-i-explorer-kit:OM5569-NT322E"
#define URL_WEB_LINK_DATASHEET   @"http://www.nxp.com/documents/data_sheet/NT3H2111_2211.pdf"
#define URL_WEB_LINK_USERMANUAL  @"http://www.nxp.com/documents/user_manual/UM10966.pdf"
#define URL_WEB_LINK_DESIGNFILES @"http://www.nxp.com/documents/software/SW3638.zip"
#define URL_WEB_LINK_SRC         @"http://www.nxp.com/demoboard/OM5569"

#define MSG_TAG_SUCCESS_PROTEC   @"Tag Successfully Protected!"
#define MSG_TAG_SUCCESS_UNPROTEC @"Tag Successfully Unprotected!"
#define MSG_TAG_PROTECTED        @"PROTECTED"
#define MSG_TAG_UNPROTECTED      @"UNPROTECTED"
#define MSG_TAG_WRONGPASS        @"Wrong Password!"
#define MSG_ERROR_RST            @"Error during reset!"
#define MSG_CAP_CON_WRONG        @"Capability container wrong (use I2C instead to reset)"
#define MSG_DYN_LOCK_BITS        @"Dynamic Lock bits set, cannot reset"
#define MSG_ERROR_FORMAT         @"Error during formatting!"
#define MSG_WRITING_PROCES       @"Writing in process"
#define MSG_TAG_WRONGINPUT_PARAMS   @"Wrong input parameters!"
#define MSG_AUTH_REQ             @"Authentication Required"
#define MSG_ERROR_TRANS          @"Error during transmission"
#define MSG_ERROR_FLASH          @"Error during flashing!"
#define MSG_NOT_SUP_BOARD        @"Not supported board type!"

#define IMG_SRC_LOCK             @"lock.png"
#define IMG_SRC_OPEN             @"open.png"


#define IMG_SRC_NO_PRESSED       @"no_pressed"
#define IMG_SRC_LEFT_PRESSED     @"left_pressed"
#define IMG_SRC_MID_PRESSED      @"middle_pressed"
#define IMG_SRC_LEFT_MID_PRESSED @"left_middle_pressed"
  
#define IMG_SRC_RIGHT_PRESSED       @"right_pressed"
#define IMG_SRC_RIGHT_LEFT_PRESSED  @"right_left_pressed"
#define IMG_SRC_MID_RIGHT_PRESSED   @"middle_right_pressed"
#define IMG_SRC_ALL_PRESSED         @"all_pressed"
#define IMG_SRC_NO_PRESSED          @"no_pressed"
#define IMG_CHECKBOX_ON             @"checkbox_on"
#define IMG_CHECKBOX_OFF            @"checkbox_off"

#define TXT_AUTH_DISMISS         @"AUTH VC DISMISS"
#define TXT_IMG_CHANGE_NOTIFY    @"ImageChangeNotification"
#define TXT_SB_MAIN              @"Main"
#define TXT_AUTH_ID              @"AUTH_ID"
#define TXT_TITLE_FEEDBACK       @"NTAG I2C Demo Feedback"
#define TXT_IC_PROD              @"IC Product"
#define TXT_USER_MEMORY          @"User Memory"
#define TXT_FD_OFF               @"FD_OFF"
#define TXT_FD_ON                @"FD_ON"
#define TXT_PT                   @"PT"
#define TXT_RFTOI2C              @"RFTOI2C"
#define TXT_LAST_NDEF_BLOCK      @"Last NDEF Block"
#define TXT_SRAM_MIRROR_BLOCK    @"SRAMMirrorBlock"
#define TXT_WD_LS                @"WD_LS"
#define TXT_WD_MS                @"WD_MS"
#define TXT_I2C_CLOCK            @"I2CClockStretch"
#define TXT_I2C_RST              @"I2C_RST_ON_OFF"
#define TXT_AUTH0                @"Auth0"
#define TXT_NFC_PROT             @"NFCProt"
#define TXT_NFC_DIS_SEC1         @"NFC_DIS_SEC_1"
#define TXT_AUTH_LIM             @"AuthLIM"
#define TXT_PROT2K               @"Prot2k"
#define TXT_SRAMPROT             @"SRAMProt"
#define TXT_I2CPROT              @"I2cProt"
#define TXT_READING_INFO         @"Reading information..."
#define TXT_NO_BOARD_ATTACHED    @"No board attached!"
#define TXT_FLASH_IN_PROGRESS    @"Flashing in progress..."
#define TXT_SUCCESS              @"Success!"
#define TXT_I2C_CLOCK            @"I2CClock"
#define TXT_SRAM_MIRROR          @"SRAMMirror"
#define TXT_SRAM_RF_READY        @"SRAMRFReady"
#define TXT_SRAM_I2C_READY       @"SRAMI2CReady"
#define TXT_RF_LOCKED            @"RFLocked"
#define TXT_I2_LOCKED            @"I2Locked"
#define TXT_RF_FIELD_PRESENT     @"RF Field present"
#define TXT_NDEF_DATA_READ       @"NDEF Data Read"
#define TXT_RST_START            @"RST on Start"
#define TXT_FORMATTING           @"Formatting..."
#define TXT_RES_COMPLETE         @"Reset Completed!"
#define TXT_TEMP_NOT_AVA         @"Temperature: Not available"
#define TXT_TRANS_NON            @"Transfer: non"
#define TXT_TRANS_DEV_TAG        @"Transfer: Device --> Tag";
#define TXT_TRANS_TAG_DEV        @"Transfer: Device <-- Tag";
#define TXT_WRITING_NDEF         @"Writing NDEF..."
#define TXT_READING_NDEF         @"Reading NDEF..."
