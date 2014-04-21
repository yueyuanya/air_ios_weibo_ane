/*
 
 Copyright (c) 2012, DIVIJ KUMAR
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met: 
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer. 
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution. 
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 The views and conclusions contained in the software and documentation are those
 of the authors and should not be interpreted as representing official policies, 
 either expressed or implied, of the FreeBSD Project.
 
 
 */

/*
 * WeiboAPI.m
 * WeiboAPI
 *
 * Created by yueyuanya on 14-4-9.
 * Copyright (c) 2014年 __MyCompanyName__. All rights reserved.
 * 接口 由as ExtendContext调用
 * 注册key registerKey(key,redirecturl)
 * 授权 auth
 * 分享 share(message,bitmapdata)
 * 覆盖url openURL 需监听InvokeEvent 后调用openURL
 */

#import "WeiboAPI.h"

@implementation WeiboDelegate
FREContext g_ctx;
WeiboManager *manager;
id me;
/* WeiboAPIExtInitializer()
 * The extension initializer is called the first time the ActionScript side of the extension
 * calls ExtensionContext.createExtensionContext() for any context.
 *
 * Please note: this should be same as the <initializer> specified in the extension.xml 
 */
void WeiboAPIExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet) 
{
    NSLog(@"Entering WeiboAPIExtInitializer()");
    
    *extDataToSet = NULL;
    *ctxInitializerToSet = &ContextInitializer;
    *ctxFinalizerToSet = &ContextFinalizer;

    NSLog(@"Exiting WeiboAPIExtInitializer()");
}

/* WeiboAPIExtFinalizer()
 * The extension finalizer is called when the runtime unloads the extension. However, it may not always called.
 *
 * Please note: this should be same as the <finalizer> specified in the extension.xml 
 */
void WeiboAPIExtFinalizer(void* extData) 
{
    NSLog(@"Entering WeiboAPIExtFinalizer()");
     
    // Nothing to clean up.
    NSLog(@"Exiting WeiboAPIExtFinalizer()");
    return;
}

/* ContextInitializer()
 * The context initializer is called when the runtime creates the extension context instance.
 */
void ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    g_ctx=ctx;
    manager=[WeiboManager alloc];
    manager.g_ctx=ctx;
    NSLog(@"Entering ContextInitializer()");
        /* The following code describes the functions that are exposed by this native extension to the ActionScript code.
     */
    static FRENamedFunction func[] = 
    {
        MAP_FUNCTION(isSupported, NULL),
        MAP_FUNCTION(response, NULL),
        MAP_FUNCTION(share, NULL),
        MAP_FUNCTION(openURL,NULL),
        MAP_FUNCTION(auth,NULL),
        MAP_FUNCTION(registerKey,NULL)
    };
    
    *numFunctionsToTest = sizeof(func) / sizeof(FRENamedFunction);
    *functionsToSet = func;
    
    NSLog(@"Exiting ContextInitializer()");
}

/* ContextFinalizer()
 * The context finalizer is called when the extension's ActionScript code
 * calls the ExtensionContext instance's dispose() method.
 * If the AIR runtime garbage collector disposes of the ExtensionContext instance, the runtime also calls ContextFinalizer().
 */
void ContextFinalizer(FREContext ctx) 
{
    NSLog(@"Entering ContextFinalizer()");

    // Nothing to clean up.
    NSLog(@"Exiting ContextFinalizer()");
    return;
}
/*
 *invoke openURL 
 *air invoke event to here
 */
ANE_FUNCTION(openURL)
{
    uint32_t len;
    const uint8_t* url=nil;
    FREGetObjectAsUTF8(argv[0], &len, &url);// argv[0]
    //
    NSString *str = [[NSString alloc] initWithString:[NSString stringWithUTF8String:(const char*)url]];
    NSURL *nurl=[NSURL URLWithString:str];
    [WeiboSDK handleOpenURL:nurl delegate:manager];
    
}

 
/**
 *分享接口 share
 *参数 params 1 message 2 bitmapdata
 *
 */
ANE_FUNCTION(share)
{
    WBMessageObject *message = [WBMessageObject message];
    uint32_t len;
    const uint8_t* content=nil;
    FREGetObjectAsUTF8(argv[0], &len, &content);// argv[0]
    //
    NSString *str = [[NSString alloc] initWithString:[NSString stringWithUTF8String:(const char*)content]];
    message.text = str;//@"测试通过WeiboSDK发送文字到微博!";
  
    //从参数组argv中拿出AS的BitmapData对象，用FREAcquireBitmapData方法将bitmapData指针指向这个BitmapData对象。
    //这样，只要改动bitmapData的位图信息，就会直接影响 AS里面创建的BitmapData对象。
 
    FREObject objectBitmapData = argv[1];
    FREBitmapData2 bitmapData; FREAcquireBitmapData2(objectBitmapData, &bitmapData );
    int width = bitmapData.width;
    int height = bitmapData.height;
    int stride = bitmapData.lineStride32 * 4;
    uint32_t* input = bitmapData.bits32;
    // make data provider from buffer
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bitmapData.bits32, (width * height * 4), NULL); // set up for CGImage creation
    int bitsPerComponent = 8; int bitsPerPixel = 32; int bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo;
    
    if( bitmapData.hasAlpha ) {
        if( bitmapData.isPremultiplied )
            bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
        else bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaFirst; }
    else { bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst; }
    
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent); // make UIImage from CGImage
    UIImage *myImage = [UIImage imageWithCGImage:imageRef];
    
    NSData* jpgData = UIImageJPEGRepresentation( myImage, 0.9 );
    FREReleaseBitmapData( objectBitmapData );
    WBImageObject *image = [WBImageObject object];
    image.imageData =jpgData;//[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_1" ofType:@"jpg"]];
    message.imageObject = image;
//    
    WBWebpageObject *webpage = [WBWebpageObject object];
    webpage.objectID = @"identifier1";
    webpage.title = @"分享网页标题";
    webpage.description = [NSString stringWithFormat:@"分享网页内容简介-%.0f", [[NSDate date] timeIntervalSince1970]];
    webpage.thumbnailData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_2" ofType:@"jpg"]];
    webpage.webpageUrl = @"http://sina.cn?a=1";
    //message.mediaObject = webpage;
    

    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage: message];
    request.userInfo = @{@"ShareMessageFrom": @"SendMessageToWeiboViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
      //  request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    
    [WeiboSDK sendRequest:request];
    //
    
    FREObject fo;
    
    //FREResult aResult = FRENewObjectFromBool(YES, &fo);
    FREResult aResult=FRENewObjectFromInt32(55,  &fo);
    if (aResult == FRE_OK)
    {
        NSLog(@"Result = %d", aResult);
    }
    else
    {
        NSLog(@"Result = %d", aResult);
    }
    NSLog(@"Exiting IsSupported()");
	return fo;
    
}

/* This is a TEST function that is being included as part of this template.
 * isSupported
 */
ANE_FUNCTION(isSupported)
{
    NSLog(@"Entering IsSupported()");
    
    FREObject fo;
    
   FREResult aResult = FRENewObjectFromBool(YES, &fo);
    if (aResult == FRE_OK)
    {
        NSLog(@"Result = %d", aResult);
    }
    else
    {
        NSLog(@"Result = %d", aResult);
    }
    
	NSLog(@"Exiting IsSupported()");    
	return fo;
}
//register appkey
ANE_FUNCTION(registerKey)
{
    NSLog(@"Entering registerKey()");
    
    uint32_t len;
    const uint8_t* content=nil;
    FREGetObjectAsUTF8(argv[0], &len, &content);// argv[0]
    //
    NSString *appkey = [[NSString alloc] initWithString:[NSString stringWithUTF8String:(const char*)content]];
    manager.appkey=appkey;
    
    uint32_t len2;
    const uint8_t* contentURL=nil;
    FREGetObjectAsUTF8(argv[1], &len2, &contentURL);// argv[0]
    //
    NSString *redirectURL = [[NSString alloc] initWithString:[NSString stringWithUTF8String:(const char*)contentURL]];
    manager.redirectURL=redirectURL;
    
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:appkey];
    
    FREObject fo;
    
    FREResult aResult = FRENewObjectFromBool(YES, &fo);
    if (aResult == FRE_OK)
    {
        NSLog(@"Result = %d", aResult);
    }
    else
    {
        NSLog(@"Result = %d", aResult);
    }
    
	NSLog(@"Exiting registerKey()");
	return fo;
}
//授权 auth
ANE_FUNCTION(auth)
{
    NSLog(@"Entering auth()");
    
       uint32_t len;
    const uint8_t* content=nil;
    FREResult foread=FREGetObjectAsUTF8(argv[0], &len, &content);// argv[0]
    
     NSString *str =@"all";
    
    if(foread==FRE_OK){
        str=[[NSString alloc] initWithString:[NSString stringWithUTF8String:(const char*)content]];
    }else{
        
    }
    //
    
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = manager.redirectURL;
    request.scope = str;
    request.userInfo = @{@"SSO_From": @"SendMessageToWeiboViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    [WeiboSDK sendRequest:request];
    
	NSLog(@"Exiting auth()");
    FREObject fo;
    
    //FREResult aResult = FRENewObjectFromBool(YES, &fo);
    FREResult aResult = FRENewObjectFromBool(YES, &fo);
    if (aResult == FRE_OK)
    {
        NSLog(@"Result = %d", aResult);
    }
    else
    {
        NSLog(@"Result = %d", aResult);
    }

	return fo;
}
//test
ANE_FUNCTION(response)
{
    FREObject fo;
    
    //FREResult aResult = FRENewObjectFromBool(YES, &fo);
    NSString *coder=@"test";
    FREResult aResult=FRENewObjectFromUTF8(4,  (const uint8_t *)[coder UTF8String], &fo);
    if (aResult == FRE_OK)
    {
        NSLog(@"Result = %d", aResult);
    }
    else
    {
        NSLog(@"Result = %d", aResult);
    }
    
	NSLog(@"Exiting IsSupported()");
	return fo;
}
@end
