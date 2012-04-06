//
//  Copyright (c) 2012年 www.angeleyes.it. All rights reserved.
//
//  ViewController.m
//  AngelEyesRMB
//
//  Created by koupoo
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  

#import "ViewController.h"
#import "AngelEyes.h"
#import "BlockViewStyle1.h"
#import "BlockViewStyle3.h"

typedef enum{
	ViewBlockViewINVALID = 0,
    ViewBlockViewIdentify,
	ViewBlockViewMAX
}LoginViewBlockView;


@interface ViewController ()

@property (nonatomic, retain) UIImagePickerController *imagePicker;
@property (nonatomic, retain) UIImage *currentImage;
@property (atomic, retain) NSThread *currentIdentifyThread;
@property (nonatomic, retain) AngelEyes *angelEyes;

- (void)createImagePicker;

@end


@implementation ViewController
@synthesize rmbImageView;
@synthesize identifyResultLabel;
@synthesize imagePicker;
@synthesize currentImage;
@synthesize currentIdentifyThread;
@synthesize angelEyes;

-(void)blockIdentify{
	NSString *blockViewIdentifier = [NSString stringWithFormat:@"%d",  ViewBlockViewIdentify];
	
	if([blockViewDict valueForKey:blockViewIdentifier] != nil)
		return;
    
    
    CGRect blockViewPart1Frame = self.view.frame;
    blockViewPart1Frame.origin.x = 0;
    blockViewPart1Frame.origin.y = 0;
    blockViewPart1Frame.size.height -= 80;
    
	BlockViewStyle1 *blockViewPart1 = [[BlockViewStyle1 alloc] initWithFrame:blockViewPart1Frame];
	blockViewPart1.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
	blockViewPart1.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
    NSMutableArray *animationImages = [NSMutableArray arrayWithCapacity:24];
    
    for(int imageIdx = 0; imageIdx < 24; imageIdx++){
        [animationImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"angeleyes%02d.png", imageIdx + 1]]];
    }
    
    
    BlockViewStyle3 *blockViewPart2 = [[BlockViewStyle3 alloc] initWithFrame:CGRectMake(0, 0, 100, 100) indicatorTitle:@"识别中..." animationImages:animationImages animationDuration:1.5];
    
    blockViewPart2.activityIndicatorView.bounds = CGRectMake(0, 0, 25, 25);
	blockViewPart2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
	|UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	blockViewPart2.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
	[blockViewPart2.indicatorLabel setFont:[UIFont systemFontOfSize:15]];
	[blockViewPart2.indicatorLabel setTextColor:[UIColor whiteColor]];
	[blockViewPart2.activityIndicatorView startAnimating];
	
	blockViewPart2.center = CGPointMake(blockViewPart1.frame.size.width / 2, blockViewPart1.frame.size.height / 2);
	[blockViewPart1 addSubview:blockViewPart2];
	
	[blockViewPart2 release];
	
	UIView *blockView = blockViewPart1;
    
	[self.view addSubview:blockView];
	[blockViewDict setValue:blockView forKey:[NSString stringWithFormat:@"%d",  ViewBlockViewIdentify]];
	
	[blockViewPart1 release];
}

- (void)unblockIdentifyAnimated:(BOOL)animated{
	NSString *blockViewIdentifier = [NSString stringWithFormat:@"%d",  ViewBlockViewIdentify];
	UIView *blockView = [blockViewDict valueForKey:blockViewIdentifier];
	
	if(blockView == nil)
		return;
	
	if (animated == YES) {
		[UIView animateWithDuration:1
						 animations:^{
							 blockView.alpha = 0;
						 } completion:^(BOOL finished){
							 [blockView removeFromSuperview];
							 [blockViewDict removeObjectForKey:blockViewIdentifier];
						 }
		 ];
	}
	else {
		[blockView removeFromSuperview];
		[blockViewDict removeObjectForKey:blockViewIdentifier];
	}
}

- (void)showIdentifyResult:(NSDictionary *)result{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    [self unblockIdentifyAnimated:YES];
    
    if (result == nil || ![result isKindOfClass:[NSDictionary class]]) {
        identifyResultLabel.text = @"无法识别";
    }
    else{
        if ([[result valueForKey:@"tags"] count] > 0) {
            identifyResultLabel.text = [[result valueForKey:@"tags"] objectAtIndex:0];
        }
        else
            identifyResultLabel.text = @"无法识别";
        
    }
    
    [pool drain];
}

- (void)showIdentifyError:(NSError *)error{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    [self unblockIdentifyAnimated:YES];
    
    if ([[[error userInfo] valueForKey:@"message"] length] > 0) {
        identifyResultLabel.text = [[error userInfo] valueForKey:@"message"];
    }
    else
        identifyResultLabel.text = @"无法识别";
    
    [pool drain];
}

- (void)identifyImage:(UIImage *)image{
     NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSError *error = nil;
    
    CGRect roi = CGRectMake(0, 0, image.size.width, image.size.height);
    NSDictionary *result = [angelEyes identifyImage:image roi:roi r:0.24 rr:0.24 maxDrif:19 kpCount:255 scale:0.9 error:&error];
    
    if ([[NSThread currentThread] isCancelled]) {
        NSLog(@"thread is canceled");
        [pool drain];
        [NSThread exit];
    }
    else{
        if (error != nil) {
            [self performSelectorOnMainThread:@selector(showIdentifyError:) withObject:error waitUntilDone:YES];
        }
        else{
            [self performSelectorOnMainThread:@selector(showIdentifyResult:) withObject:result waitUntilDone:YES];
        }
    }
    
    [pool drain];
}

- (void)createImagePicker {
    if(imagePicker == nil){
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = [[[NSArray alloc] initWithObjects:@"public.image", nil] autorelease];
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        imagePicker.cameraDevice      = UIImagePickerControllerCameraDeviceRear;
        imagePicker.cameraFlashMode   = UIImagePickerControllerCameraFlashModeAuto;
        imagePicker.showsCameraControls = YES;
        imagePicker.delegate = self;
    }
}

- (void)cancelIdentify{
    [currentIdentifyThread cancel];
    self.currentIdentifyThread = nil;
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info { 
    [currentImage release];
    
    currentImage = [[info valueForKey:UIImagePickerControllerOriginalImage] retain];
    
    rmbImageView.image = currentImage;
    
    [self dismissModalViewControllerAnimated:NO];
    identifyResultLabel.text = nil;
    
    [self cancelIdentify];
    [self blockIdentify];
    
    currentIdentifyThread = [[NSThread alloc] initWithTarget:self selector:@selector(identifyImage:) object:currentImage];
    [currentIdentifyThread start];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissModalViewControllerAnimated:NO];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    exit(0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceRear]) {
        [self createImagePicker];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Camera Not Available" 
                                                            message:@"AngelEyesRMB Demo needs camera, while camera on this iOS platform is not available."
                                                           delegate:self 
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"EXIT",
                                  nil];
        [alertView show];
        [alertView release];
    
    }
	
    rmbImageView.image = currentImage;
    
    if (blockViewDict == nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"拍照识别提示" 
                                                            message:@"给人民币拍张照，让我认认它是多少钱。"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"知道了",
                                  nil];
        [alertView show];
        [alertView release];
        
        
        blockViewDict = [[NSMutableDictionary alloc] init];

        //本appkey和appsecet的最终解释权归www.angeleyes.it所有
        //本appkey和appsecet将在2012/07/06 18:00:00失效。
        angelEyes = [[AngelEyes alloc] initWithAppKey:@"4f5f2e2868fb7" appSecret:@"ff8d1ad73d71ad63ff3e8847b5cb12e4"];  
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{    
    if(UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        return YES;
    }
    else
        return NO;
}

- (void)dealloc {
    [rmbImageView release];
    [identifyResultLabel release];
    [imagePicker release];
    [currentImage release];
    [blockViewDict release];
    [currentIdentifyThread cancel];
    [currentIdentifyThread release];
    [angelEyes release];
    [super dealloc];
}


- (IBAction)takePhoto:(id)sender {
    imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentModalViewController:imagePicker animated:NO];
}

- (IBAction)cancelIdentify:(id)sender {
    [self unblockIdentifyAnimated:NO];
    [self cancelIdentify];
}

@end
