//
//  NSString+Encode.m
//  PocketStretch
//
//  Created by Emmanuel Franco on 8/8/15.
//  Copyright (c) 2015 Emmanuel Franco. All rights reserved.
//

#import "NSString+Encode.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation NSString (Encode)

-(NSString *)encodeString:(NSStringEncoding)encoding
{
    //return (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@";/?:@&=$+{}<>,", CFStringConvertNSStringEncodingToEncoding(encoding)));
    
   // NSMutableCharacterSet* URLCharacters = [[NSCharacterSet URLHostAllowedCharacterSet] mutableCopy];
    
    NSCharacterSet* additionalSet = [NSCharacterSet characterSetWithCharactersInString:@" '=;\"#%/:<>?@&$+[\\]^`{|},"].invertedSet;
    
    //[URLCharacters addCharactersInString:@"=;?:@&=$+{}<>,"];
    
    //NSCharacterSet* finalURLCharacterSet = [URLCharacters copy];
    
    return [self stringByAddingPercentEncodingWithAllowedCharacters:additionalSet];

}

+ (NSString *)hash:(NSString *)data secret:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *hmac = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];
    
    NSString* hash = [hmac base64EncodedStringWithOptions:0];
    
    //NSMutableString* hash = [[NSMutableString alloc]init];
//    const char* bytes = [hmac bytes];
//    for (int i = 0; i < [hmac length]; i++) {
//        [hash appendFormat:@"%02.2hhx", bytes[i]];
//    }
    
    return hash;
}

@end
