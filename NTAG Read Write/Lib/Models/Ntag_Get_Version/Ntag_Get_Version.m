//  Copyright 2019 mobileknowledge. All rights reserved.
//

#import "Ntag_Get_Version.h"

@implementation Ntag_Get_Version

char NTAG_I2C_1k_bytes [] =       {0x00, 0x04, 0x04, 0x05, 0x01, 0x01, 0x13, 0x03};
char NTAG_I2C_2k_bytes [] =       {0x00, 0x04, 0x04, 0x05, 0x01, 0x01, 0x15, 0x03};

char NTAG_I2C_1k_V_bytes [] =     {0x00, 0x04, 0x04, 0x05, 0x02, 0x00, 0x13, 0x03};
char NTAG_I2C_2k_V_bytes [] =     {0x00, 0x04, 0x04, 0x05, 0x02, 0x00, 0x15, 0x03};

char NTAG_I2C_1k_T_bytes [] =     {0x00, 0x04, 0x04, 0x05, 0x02, 0x01, 0x13, 0x03};
char NTAG_I2C_2k_T_bytes [] =     {0x00, 0x04, 0x04, 0x05, 0x02, 0x01, 0x15, 0x03};

char NTAG_I2C_1k_Plus_bytes [] =  {0x00, 0x04, 0x04, 0x05, 0x02, 0x02, 0x13, 0x03};
char NTAG_I2C_2k_Plus_bytes [] =  {0x00, 0x04, 0x04, 0x05, 0x02, 0x02, 0x15, 0x03};

char MTAG_I2C_1k_bytes [] =       {0x00, 0x04, 0x05, 0x07, 0x02, 0x02, 0x13, 0x03};
char MTAG_I2C_2k_bytes [] =       {0x00, 0x04, 0x05, 0x07, 0x02, 0x02, 0x15, 0x03};

char TNPI_6230_bytes [] =         {0x00, 0x04, 0x05, 0x05, 0x01, 0x01, 0x15, 0x03};
char TNPI_3230_bytes [] =         {0x00, 0x04, 0x05, 0x05, 0x01, 0x01, 0x13, 0x03};


- (id) initWithData: (NSData *) data{
    self = [super init];
    
    if (data.length == 0)
        return self;
    
    const char * bytes = [data bytes];
    
    [self setVendorID:bytes[1]];
    //[self setProdType:bytes[2]];
    [self setProductSubtype:bytes[3]];
    [self setMajorProductVersion:bytes[4]];
    [self setMinorProductVersion:bytes[5]];
    [self setStorageSize:bytes[6]];
    [self setProtocolType:bytes[7]];
    [self setProdType:data];
    [self setSramSector];
    
    return self;
}

- (void)setVendorID:(Byte)vendor_ID{
    _vendor_ID = vendor_ID;
}
- (void)setProductType:(Byte)product_type{
    _product_type = product_type;
}
- (void)setProductSubtype:(Byte)product_subtype{
    _product_subtype = product_subtype;
}
- (void)setMajorProductVersion:(Byte)major_product_version{
    _major_product_version = major_product_version;
}
- (void)setMinorProductVersion:(Byte)minor_product_version{
    _minor_product_version = minor_product_version;
}
- (void)setStorageSize:(Byte)storage_size{
    _storage_size = storage_size;
}
- (void)setProtocolType:(Byte)protocol_type{
    _protocol_type = protocol_type;
}

- (void)setSramSector {
     if (_product == NTAG_I2C_2K)
            [self setSram_sector:1];
        else
            [self setSram_sector:0];
}

- (void)setProdType:(NSData *)data{
    
    if ([data isEqualToData:  [[NSData alloc]initWithBytes:NTAG_I2C_1k_bytes length:sizeof(NTAG_I2C_1k_bytes)]] ){
        self.product = NTAG_I2C_1K;
        self.mem_size = 888;
    }
    
    else if([data isEqualToData:  [[NSData alloc]initWithBytes:NTAG_I2C_2k_bytes length:sizeof(NTAG_I2C_2k_bytes)]] ){
        self.product = NTAG_I2C_2K;
        self.mem_size = 1904;
    }
    else if([data isEqualToData:  [[NSData alloc]initWithBytes:NTAG_I2C_1k_T_bytes length:sizeof(NTAG_I2C_1k_T_bytes)]] ){
        self.product = NTAG_I2C_1K_T;
        self.mem_size = 888;
    }
    
    else if([data isEqualToData:  [[NSData alloc]initWithBytes:NTAG_I2C_2k_T_bytes length:sizeof(NTAG_I2C_2k_T_bytes)]] ){
        self.product = NTAG_I2C_2K_T;
        self.mem_size = 1904;
    }
    
    else if([data isEqualToData:  [[NSData alloc]initWithBytes:NTAG_I2C_1k_V_bytes length:sizeof(NTAG_I2C_1k_V_bytes)]] ){
        self.product = NTAG_I2C_1K_V;
        self.mem_size = 888;
    }
    
    else if([data isEqualToData:  [[NSData alloc]initWithBytes:NTAG_I2C_2k_V_bytes length:sizeof(NTAG_I2C_2k_V_bytes)]] ){
        self.product = NTAG_I2C_2K_V;
        self.mem_size = 1904;
    }
    
    else if([data isEqualToData: [[NSData alloc]initWithBytes:NTAG_I2C_1k_Plus_bytes length:sizeof(NTAG_I2C_1k_Plus_bytes)]] ){
        self.product = NTAG_I2C_1K_PLUS;
        self.mem_size = 888;
    }
    
    else if([data isEqualToData:  [[NSData alloc]initWithBytes:NTAG_I2C_2k_Plus_bytes length:sizeof(NTAG_I2C_2k_Plus_bytes)]] ){
        self.product = NTAG_I2C_2K_PLUS;
        self.mem_size = 1912;
    }
    
    else if([data isEqualToData:  [[NSData alloc]initWithBytes:MTAG_I2C_1k_bytes length:sizeof(MTAG_I2C_1k_bytes)]] ){
        self.product = MTAG_I2C_1K;
        self.mem_size = 720;
    }
    
    else if([data isEqualToData:  [[NSData alloc]initWithBytes:MTAG_I2C_2k_bytes length:sizeof(MTAG_I2C_2k_bytes)]] ){
        self.product = MTAG_I2C_2K;
        self.mem_size = 1440;
    }
    
    else if([data isEqualToData:  [[NSData alloc]initWithBytes:TNPI_6230_bytes length:sizeof(TNPI_6230_bytes)]] ){
        self.product = TNPI_6230;
        self.mem_size = 0;
    }
    
    else if([data isEqualToData:  [[NSData alloc]initWithBytes:TNPI_3230_bytes length:sizeof(TNPI_3230_bytes)]] ){
        self.product = TNPI_3230;
        self.mem_size = 0;
    }
    else{
        self.product = UNKNOWN;
        self.mem_size = 0;
    }
}

- (int) getMemsize: (Prod) product{
    
    if (product == NTAG_I2C_1K || product == NTAG_I2C_1K_T || product == NTAG_I2C_1K_V || product == NTAG_I2C_1K_PLUS)
        return 888;
    else if (product == NTAG_I2C_2K || product == NTAG_I2C_2K_T || product == NTAG_I2C_2K_V )
        return 1904;
    else if (product == NTAG_I2C_2K_PLUS)
        return 1912;
    else if (product == MTAG_I2C_1K)
        return 720;
    else if (product == MTAG_I2C_2K)
        return 1440;
    else
        return 0;
}


- (Byte)getVendorID{
    return _vendor_ID;
}

- (Byte)getProductType{
    return _product_type;
}

- (Byte)getProductSubtype{
    return _product_subtype;
}

- (Byte)getMajorProductVersion{
    return _major_product_version;
}

- (Byte)getMinorProductVersion{
    return _minor_product_version;
}

- (Byte)getStorageSize{
    return _storage_size;
}

- (Byte)getProtocolType{
    return _protocol_type;
}

- (Byte)getSramSector{
    return _sram_sector;
}

- (Prod)getProdType{
    return _product;
}

- (int) getMemsize{
    return self.mem_size;
}


@end
