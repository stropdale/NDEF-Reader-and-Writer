//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Ntag_Get_Version : NSObject

typedef enum ProdTypes
{
    NTAG_I2C_1K,
    NTAG_I2C_2K,
    NTAG_I2C_1K_T,
    NTAG_I2C_2K_T,
    NTAG_I2C_1K_V,
    NTAG_I2C_2K_V,
    NTAG_I2C_1K_PLUS,
    NTAG_I2C_2K_PLUS,
    MTAG_I2C_1K,
    MTAG_I2C_2K,
    TNPI_6230,
    TNPI_3230,
    UNKNOWN
} Prod;

@property (nonatomic, assign) Byte vendor_ID;
@property (nonatomic, assign) Byte product_type;
@property (nonatomic, assign) Byte product_subtype;
@property (nonatomic, assign) Byte major_product_version;
@property (nonatomic, assign) Byte minor_product_version;
@property (nonatomic, assign) Byte storage_size;
@property (nonatomic, assign) Byte protocol_type;
@property (nonatomic, assign) Byte sram_sector;
@property (nonatomic, assign) Prod product;
@property (assign) int mem_size;

- (id) initWithData: (NSData *) data;

- (void)setVendorID:(Byte)vendor_ID;
- (void)setProductType:(Byte)product_type;
- (void)setProductSubtype:(Byte)product_subtype;
- (void)setMajorProductVersion:(Byte)major_product_version;
- (void)setMinorProductVersion:(Byte)minor_product_version;
- (void)setStorageSize:(Byte)storage_size;
- (void)setProtocolType:(Byte)protocol_type;
- (void)setSramSector:(Byte)sram_sector;
- (void)setProdType:(NSData *)data;

- (Byte)getVendorID;
- (Byte)getProductType;
- (Byte)getProductSubtype;
- (Byte)getMajorProductVersion;
- (Byte)getMinorProductVersion;
- (Byte)getStorageSize;
- (Byte)getProtocolType;
- (Byte)getSramSector;
- (Prod)getProdType;
- (int) getMemsize;
- (int) getMemsize: (Prod) product;

@end
