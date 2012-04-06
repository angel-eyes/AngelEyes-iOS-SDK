//
//  AngelEyes.m
//  AngelEyes_IOS_SDK
//
//  Copyright 2012 www.angeleyes.it. All rights reserved
//
//  Created by koupoo
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "AngelEyes.h"
#import "SBJson.h"

#define kStrBoundary @"3i2ndDfv2rTHiSisAbouNdArYfORhtTPEefj3q2f"
#define kErrorDomain @"ERROR.SDK.IOS.ANGELEYES.IT"
#define kKeyErrorMessage @"message"

#define AE_IMAGE_DEFAULT_MAX_WIDTH  256
#define AE_IMAGE_DEFAUL_MIN_WIDTH 20


@interface AngelEyes()

@property (nonatomic, retain) NSString *appKey;
@property (nonatomic, retain) NSString *appSecret;

@end


@implementation AngelEyes

@synthesize appKey;
@synthesize appSecret;


+ (UIImage*)subImage:(CGRect)rect fromImage:(UIImage *)srcImage 
{  
    if (srcImage .scale > 1.0f) {
        rect = CGRectMake(rect.origin.x * srcImage.scale,
                          rect.origin.y * srcImage.scale,
                          rect.size.width * srcImage.scale,
                          rect.size.height * srcImage .scale);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(srcImage.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:srcImage.scale orientation:srcImage.imageOrientation];
    CGImageRelease(imageRef);
    return result;
} 


+ (void)utfAppendBody:(NSMutableData *)body data:(NSString *)data {
    [body appendData:[data dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSData *)postBodyWithParams:(NSDictionary *)params {
    NSMutableData *body = [NSMutableData data];
    NSString *endLine = [NSString stringWithFormat:@"\r\n--%@\r\n", kStrBoundary];
    NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
    
    [self utfAppendBody:body data:[NSString stringWithFormat:@"--%@\r\n", kStrBoundary]];
    
    for (id key in [params keyEnumerator]) {
        if ([[params valueForKey:key] isKindOfClass:[UIImage class]]) {
            [dataDictionary setObject:[params valueForKey:key] forKey:key];
            continue;
            
        }
        
        [self utfAppendBody:body
                       data:[NSString
                             stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",
                             key]];
        [self utfAppendBody:body data:[params valueForKey:key]];
        
        [self utfAppendBody:body data:endLine];
    }
    
    if ([dataDictionary count] > 0) {
        for (id key in dataDictionary) {
            NSObject *dataParam = [dataDictionary valueForKey:key];
        
            if (![dataParam isKindOfClass:[UIImage class]]) {
                continue;
            }
            
            NSData* imageData = UIImageJPEGRepresentation((UIImage*)dataParam, 0.8);
            
            [self utfAppendBody:body
                           data:[NSString stringWithFormat:
                                 @"Content-Disposition: form-data; filename=\"%@.jpg\"; name=\"%@\"\r\n", key, key]];
            [self utfAppendBody:body
                           data:[NSString stringWithString:@"Content-Type: image/jpg\r\n\r\n"]];
            [body appendData:imageData];
            
            [self utfAppendBody:body data:endLine];
        }
    }
    
    return body;
}

+(UIImage *)thumbImageAspectFitWithSize:(CGSize)thumbImageFitSize image:(UIImage *)srcImage{
	CGSize thumbnailSize;
	if (thumbImageFitSize.width / thumbImageFitSize.height > srcImage.size.width / srcImage.size.height) {
		thumbnailSize = CGSizeMake(thumbImageFitSize.height * srcImage.size.width / srcImage.size.height , thumbImageFitSize.height);
	}
	else {
		thumbnailSize = CGSizeMake(thumbImageFitSize.width , thumbImageFitSize.width * srcImage.size.height / srcImage.size.width);
	}
	
	UIGraphicsBeginImageContext(thumbnailSize);
	[srcImage drawInRect:CGRectMake(0, 0, thumbnailSize.width, thumbnailSize.height)];
	UIImage* retimg = UIGraphicsGetImageFromCurrentImageContext();
	[[retimg retain] autorelease];
	UIGraphicsEndImageContext();
	return retimg;
}


- (id)initWithAppKey:(NSString *)_appKey appSecret:(NSString *)_appSecret{
    if (self = [super init]) {
        self.appKey = _appKey;
        self.appSecret = _appSecret;
    }
    return self;
}

- (BOOL)checkAppKeyAndAppSecret:(NSError **)err{
    if ([appKey length] == 0) {
        if (err != NULL){
            *err = [NSError errorWithDomain:kErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObject:@"appkey can't be empty" forKey:kKeyErrorMessage]];
        }
        return NO;
    }
    
    if ([appKey length] == 0) {
        if (err != NULL){
            *err = [NSError errorWithDomain:kErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObject:@"appsecret can't be empty" forKey:kKeyErrorMessage]];
        }
        return NO;
    }
    
    return YES;
}

- (NSDictionary *)sendIdentificationRequest:(NSData *)postData error:(NSError **)err{    
    NSString *url = @"http://vm-192-168-21-113.shengyun.grandcloud.cn/identify.json";
    
    NSMutableURLRequest* request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                          cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                      timeoutInterval:20];
    [request setHTTPMethod:@"POST"];
    
    NSString* contentType = [NSString
                             stringWithFormat:@"multipart/form-data; boundary=%@", kStrBoundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:postData];
    
    NSError *conErr = nil;
    
    NSData *returnData =[NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:&conErr]; 
    
    if (conErr != nil) {
        if (err != NULL) {
            *err = [NSError errorWithDomain:kErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObject:@"send request failed" forKey:kKeyErrorMessage]];
        }
        return nil;
    }
    
    NSString *returnStr = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease];
    
    SBJsonParser *jsonParser = [[SBJsonParser new] autorelease];
    
    NSError *parseErr = nil;
    id returnObj = [jsonParser objectWithString:returnStr error:&parseErr];
    
    if (parseErr == nil) {
        if ([returnObj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *returnDict = returnObj;
            
            if ([[returnDict valueForKey:@"error"] length] != 0) {
                if (err != NULL){
                    *err = [NSError errorWithDomain:kErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObject:[returnDict valueForKey:@"error"] forKey:kKeyErrorMessage]];
                }
                return nil;
            }
            else{
                if ([[returnDict valueForKey:@"tags"] isKindOfClass:[NSArray class]]) {
                    return [NSDictionary dictionaryWithObject:[returnDict valueForKey:@"tags"] forKey:@"tags"];
                }
                else{
                    if (err != NULL){
                        *err = [NSError errorWithDomain:kErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObject:@"parse response data failed" forKey:kKeyErrorMessage]];
                    }
                    return nil;
                }
            }
        }
        else{
            if (err != NULL){
                *err = [NSError errorWithDomain:kErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObject:@"parse response data failed" forKey:kKeyErrorMessage]];
            }
            return nil;
        }
    }
    else{
        if (err != NULL){
            *err = [NSError errorWithDomain:kErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObject:@"parse response data failed" forKey:kKeyErrorMessage]];
        }
       
        return nil;
    }
}


- (NSData *)createIdentificationPostData:(UIImage *)image r:(float)r rr:(float)rr maxDrift:(int)maxDrift kpCount:(int)kpCount scale:(float)scale error:(NSError **)error{
    if (image == nil) {
        if (error != NULL){
            *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObject:@"image can't be empty" forKey:kKeyErrorMessage]];
        }
        return nil;
    }

    UIImage *targetImage = nil;
    
    if (image.size.width < AE_IMAGE_DEFAUL_MIN_WIDTH || image.size.height < AE_IMAGE_DEFAUL_MIN_WIDTH){
        if (error != NULL){
            NSString *errorInfo = [NSString stringWithFormat:@"the identification area of the image is too small, must bigger than %dx%d", AE_IMAGE_DEFAUL_MIN_WIDTH, AE_IMAGE_DEFAUL_MIN_WIDTH];
            
            *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObject:errorInfo forKey:kKeyErrorMessage]];
        }
        return nil;
    }
    else if (image.size.width > AE_IMAGE_DEFAULT_MAX_WIDTH || image.size.height > AE_IMAGE_DEFAULT_MAX_WIDTH) {
        targetImage = [AngelEyes thumbImageAspectFitWithSize:CGSizeMake(AE_IMAGE_DEFAULT_MAX_WIDTH, AE_IMAGE_DEFAULT_MAX_WIDTH) image:image];
    }
    else
        targetImage = image;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    //set up post fields
    [params setValue:targetImage forKey:@"pic"];
    [params setValue:appKey forKey:@"appkey"];
    [params setValue:appSecret forKey:@"appsecret"];
    [params setValue:[NSString stringWithFormat:@"%f", r] forKey:@"r"];
    [params setValue:[NSString stringWithFormat:@"%f", rr] forKey:@"rr"];
    [params setValue:[NSString stringWithFormat:@"%d", maxDrift] forKey:@"max_drift"];
    [params setValue:[NSString stringWithFormat:@"%d", kpCount] forKey:@"kp_count"];
    [params setValue:[NSString stringWithFormat:@"%f", scale] forKey:@"scale"];
    return [AngelEyes postBodyWithParams:params];
}


- (NSDictionary *)identifyImage:(UIImage *)image error:(NSError **)error{    
    if (![self checkAppKeyAndAppSecret:error]) return nil;
    
    NSData *postData = [self createIdentificationPostData:image r:0.25 rr:0.25 maxDrift:20 kpCount:255 scale:1 error:error];
    
    if (postData == nil) {
        return nil;
    }
    
    NSDictionary *result = [self sendIdentificationRequest:postData error:error];
    return result;    
}


- (NSDictionary *)identifyImage:(UIImage *)image roi:(CGRect)roi r:(float)r rr:(float)rr maxDrif:(int)maxDrift kpCount:(int)kpCount scale:(float)scale error:(NSError **)error;{
    if (![self checkAppKeyAndAppSecret:error]) return nil;
    
    CGRect roiImageRect =  CGRectIntersection(CGRectMake(0, 0, image.size.width, image.size.height), roi);
    
    if(roiImageRect.size.width < 1 || roiImageRect.size.width < 1){
        if (error != NULL){
            *error = [NSError errorWithDomain:kErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObject:@"roi is invalid, there are not intersection between roi and image" forKey:kKeyErrorMessage]];
        }
        return nil;
    }
    
    UIImage *roiImage = [AngelEyes subImage:roiImageRect fromImage:image];
    
    NSData *postData = [self createIdentificationPostData:roiImage r:r rr:rr maxDrift:maxDrift kpCount:(int)kpCount scale:scale error:error];
    
    NSDictionary *result = [self sendIdentificationRequest:postData error:error];
    return result;    
}

- (void)dealloc{
    [appKey release];
    [appSecret release];
    [super dealloc];
}

@end

