//
//  NSData+XZDataDigester.m
//  XZKit
//
//  Created by Xezun on 2021/2/10.
//

#import "NSData+XZDataDigester.h"
#import "XZDataDigester.h"

@implementation NSData (XZDataDigester)

- (NSString *)xz_md5 {
    return [XZDataDigester digest:self algorithm:(XZDataDigesterAlgorithmMD5) hexEncoding:XZCharacterLowercase];
}

- (NSString *)xz_MD5 {
    return [XZDataDigester digest:self algorithm:(XZDataDigesterAlgorithmMD5) hexEncoding:XZCharacterUppercase];
}

- (NSString *)xz_sha1 {
    return [XZDataDigester digest:self algorithm:(XZDataDigesterAlgorithmSHA1) hexEncoding:XZCharacterLowercase];
}

- (NSString *)xz_SHA1 {
    return [XZDataDigester digest:self algorithm:(XZDataDigesterAlgorithmSHA1) hexEncoding:XZCharacterUppercase];
}

@end
