//
//  DataParser.m
//  NTAG Read Write
//
//  Created by richardstockdale on 11/03/2021.
//

#import "DataParser.h"

@implementation DataParser

- (void) updateData: (NSData *) data isTempEnabled: (bool) isTempEnabled {
    if(data.length != 64)
        return;
    
    // Processing Temperature Data
    int Temp = 0;
    const char * tempFirstByte = [[data subdataWithRange:NSMakeRange(64 - 5, 1)] bytes];
    const char * tempSecondByte = [[data subdataWithRange:NSMakeRange(64 - 6, 1)] bytes];
    
    Temp = ((tempFirstByte[0] >> 5 ) & 0x07);
    Temp |= ((tempSecondByte[0] << 3) & 0x07F8);
    
    // Process Voltage data
    int Voltage = 0;
    const char * voltageFirstByte = [[data subdataWithRange:NSMakeRange(64 - 7, 1)] bytes];
    const char * voltageSecondByte = [[data subdataWithRange:NSMakeRange(64 - 8, 1)] bytes];
    
    Voltage = ((voltageFirstByte[0] << 8) & 0xFF00) + (voltageSecondByte[0] & 0x00FF);
    
    // If Temp = 0, there is no Temperature sensor
    if (Temp != 0){} else {}
    
    if (isTempEnabled){
        NSLog(@"Temp is %f C", [self calcTempCelsius:Temp]);
        NSLog(@"Temp is %f F", [self calcTempFarenheit:Temp]);
    }
    else {
        NSLog(@"Temp is %f F",[self calcVoltage:Voltage]);
    }
}

#pragma mark - calc Temp Celsius
- (double) calcTempCelsius: (int) temp {
    double Temp_double = 0;
    
    //If the 11 Bit is 1 it is negative
    if ((temp & (1 << 11)) == (1 << 11)) {
        // Mask out the 11 Bit
        temp &= ~(1 << 11);
    }
    
    Temp_double = (double) 0.125 * temp;
    
    return Temp_double;
}

#pragma mark - calc Temp Farenheit
- (double ) calcTempFarenheit: (int) temp {
    double  Temp_double = 0;
    NSString * Temp_string = @"";
    
    //If the 11 Bit is 1 it is negative
    if ((temp & (1 << 11)) == (1 << 11)) {
        // Mask out the 11 Bit
        temp &= ~(1 << 11);
        Temp_string = [NSString stringWithFormat:@"%@%@", Temp_string, @"-"];
    }
    
    Temp_double = (double) 0.125 * temp;
    Temp_double = 32 + (1.8 * Temp_double);
    
    return Temp_double;
}

#pragma mark - calc Voltage
- (double) calcVoltage: (int) volt {
    if (volt > 0){
        double Volt_double = round((0x3FF * 2.048) / volt);
        return Volt_double;
    }
    
    return 0;
}

@end
