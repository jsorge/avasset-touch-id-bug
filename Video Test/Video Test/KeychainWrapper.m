//
//  KeychainWrapper.m
//  Video Test
//
//  Created by Jared Sorge on 3/30/17.
//  Copyright © 2017 zulily. All rights reserved.
//

#import "KeychainWrapper.h"
@import Security;

@implementation KeychainWrapper

- (BOOL)saveToKeychain:(NSData *)data withKey:(NSString *)key
{
    CFErrorRef error = nil;
    SecAccessControlRef accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, kSecAccessControlUserPresence, &error);
    
    NSDictionary *attributes = @{
                                 (__bridge id)kSecClass: (__bridge id)kSecClassInternetPassword,
                                 (__bridge id)kSecAttrAccount: key,
                                 (__bridge id)kSecValueData: data,
                                 (__bridge id)kSecAttrAccessControl: (__bridge_transfer id)accessControl
                                 };
    
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)attributes, nil);
    BOOL success = status == noErr;
    return success;
}

- (nullable NSData *)valueForKey:(NSString *)key
{
    NSDictionary *attributes = @{
                                 (__bridge id)kSecClass: (__bridge id)kSecClassInternetPassword,
                                 (__bridge id)kSecAttrAccount: key,
                                 (__bridge id)kSecReturnData: (id)kCFBooleanTrue
                                 };
    
    CFDataRef dataRef = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)attributes, (CFTypeRef *)&dataRef);
    if ((status != noErr) && (dataRef == NULL)) { return nil; }
    
    NSData *data = CFBridgingRelease(dataRef);
    return data;
}

- (BOOL)clearAll
{
    NSDictionary *attributes = @{
                                 (__bridge id)kSecClass: (__bridge id)kSecClassInternetPassword
                                 };
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)attributes);
    BOOL success = status == noErr;
    return success;
}

@end
