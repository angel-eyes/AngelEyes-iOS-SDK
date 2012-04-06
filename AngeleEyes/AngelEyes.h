//
//  AngelEyes.h
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


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface AngelEyes : NSObject

/*用指定的application key和application secret初始化并返回一个新分配的AngelEyes对象
 *@param appKey application key
 *@param appSecret application secret
 *@return 成功时，返回一个已初始化的AngelEyes对象；失败时，返回nil
 */
- (id)initWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret;

/*对指定的图片进行识别
 *使用默认的设置对图片进行识别。如果该方法的图片识率或耗时不能满足你的要求，请使用能指定识别参数的识别方法:
 *identifyImage:roi:r:rr:maxDrif:kpCount:scale:error:
 *@param image 待识别的图片
 *@param error 作为输出参数，一个指向NSError对象的指针。 当识别发生错误时，该指针将被设置为包含错误信息的一个NSError对象；如果你不需要错误
 *             信息，可将此参数设为nil。
 *@return 识别成功时，以NSDictionay对象的形式返回识别的对象的信息。目前返回NSDictioany对象只包含一个key:tags，tags所对应的的对象是
 *        一个字符串数组，这个字符串数组的第一个元素就是开发者在AngelEyes应用管理平台中为样本图片设置的标签。注意:识别成功并不代表识别准确。
 *        识别失败时，返回nil。
 */
- (NSDictionary *)identifyImage:(UIImage *)image error:(NSError **)error;


/*对指定的图片进行识别
 *使用指定的识别参数对图片进行识别。通过设置识别参数可以控制图像识别的准确率和识别耗时。
 *@param image 待识别的图片
 *@param roi 感兴趣区域，roi和CGRectMake(0, 0, 待识别的图片的宽, 待识别的图片的高)的重叠区域将作为图片的有效的识别区域。
 *@param r   初选阈值, 有效取值范围为[0.16, 0.25]。r取值越大,图片识别率越高，但识别要用的时间越长。
 *@param rr  误差平方和阈值,有效取值范围是[0.16, 0.25]。rr取值越大,图片识别率越高，但识别要用的时间越长。
 *@param maxDrift 抗皱参数,有效取值范围是[4, 36]。如果待识别图片中的待识别对象比较折皱，maxDrif应该设置大点，否则maxDrif设置小点;
 *@param kpCount 图片特征保留个数,有效取值范围是[50, 256]； kpCount取值越大,图片识别率越高，但识别要用的时间越长；
 *               如果待识别的图片比较复杂（内容比较丰富）,kpCount应该设置大点；kpCount取200时，一般能达到理想的识别准确率。
 *@param scale 图片缩放系数，有效取值范围是[0.0, 1.0]
 *@param error 作为输出参数，一个指向NSError对象的指针。 当识别发生错误时，该指针将被设置为包含错误信息的一个NSError对象；如果你不想要错误信
 *             息，可将此参数设为nil
 *@return 识别成功时，以NSDictionay对象的形式返回识别的对象的信息。目前返回NSDictioany对象只包含一个key:tags，tags所对应的的对象是
 *        一个字符串数组，这个字符串数组的第一个元素就是开发者在AngelEyes应用管理平台中为样本图片设置的标签。注意:识别成功并不代表识别准确。
 *        识别失败时，返回nil。
 */
- (NSDictionary *)identifyImage:(UIImage *)image roi:(CGRect)roi r:(float)r rr:(float)rr maxDrif:(int)maxDrift kpCount:(int)kpCount scale:(float)scale error:(NSError **)error;

@end