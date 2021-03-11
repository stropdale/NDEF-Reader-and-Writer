//
//  DataParser.h
//  NTAG Read Write
//
//  Created by richardstockdale on 11/03/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// JUST DO THIS IN OBJ C AS IT JUST NEEDS TO PROVE THE RESPONSE

@interface DataParser : NSObject

- (void) updateData: (NSData *) data isTempEnabled: (bool) isTempEnabled;

@end



NS_ASSUME_NONNULL_END
