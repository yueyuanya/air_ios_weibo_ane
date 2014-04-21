//
//  Test.h
//  WeiboAPI
//
//  Created by yueyuanya on 14-4-11.
//
//

#import <Foundation/Foundation.h>
#import "FlashRuntimeExtensions.h"
@interface WeiboManager : NSObject<WeiboSDKDelegate>
@property (nonatomic) FREContext g_ctx;
@property (nonatomic,retain) NSString *appkey;
@property (nonatomic,retain) NSString *redirectURL;
@end

