//
//  KeychainWrapper.h
//  Video Test
//
//  Created by Jared Sorge on 3/30/17.
//  Copyright © 2017 zulily. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface KeychainWrapper : NSObject
- (BOOL)saveToKeychain:(NSData *)data withKey:(NSString *)key;
- (nullable NSData *)valueForKey:(NSString *)key;
- (BOOL)clearAll;
@end
NS_ASSUME_NONNULL_END
