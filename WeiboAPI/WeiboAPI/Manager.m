//
//  ManagerHead.h
//  WeiboAPI
//
//  Created by yueyuanya on 14-4-11.
//  response处理类 委托到这来
//

#import "ManagerHead.h"

@implementation WeiboManager

-(void)setGTX:(FREContext)ctx
{
    self.g_ctx=ctx;
}


- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    if ([request isKindOfClass:WBProvideMessageForWeiboRequest.class])
    {
        
    }
}
 
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    FREDispatchStatusEventAsync(self.g_ctx, (const uint8_t*)"responseStart", (const uint8_t*)"responseStart");
    
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        
        NSString *title = @"分享";
        NSString *message = @"分享成功";//[NSString stringWithFormat:@"响应状态: %d\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",(int)response.statusCode, response.userInfo, response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        if((int)response.statusCode==WeiboSDKResponseStatusCodeSuccess){
        [alert show];
        }
        FREDispatchStatusEventAsync(self.g_ctx, (const uint8_t*)"respShare", (const uint8_t*)response.statusCode);
        
        
        [alert release];
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        NSString *title = @"认证结果";
        NSString *message = [NSString stringWithFormat:@"响应状态: %d\nresponse.userId: %@\nresponse.accessToken: %@\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",(int)response.statusCode,[(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken], response.userInfo, response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        
        NSString *token=[(WBAuthorizeResponse *)response accessToken];
         if((int)response.statusCode!=0){
             FREDispatchStatusEventAsync(self.g_ctx, (const uint8_t*)"respTokenFail", (const uint8_t*)[token UTF8String]);
             
        [alert show];
        }else{
            FREDispatchStatusEventAsync(self.g_ctx, (const uint8_t*)"respTokenSuccess", (const uint8_t*)response.statusCode);
            
        }
        [alert release];
        
    }
    FREDispatchStatusEventAsync(self.g_ctx, (const uint8_t*)"responseEnd", (const uint8_t*)"responseEnd");
    
}

@end
