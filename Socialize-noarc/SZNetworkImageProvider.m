//
//  SZSocialNetworkImageProvider.m
//  Socialize
//
//  Created by David Jedeikin on 1/13/14.
//  Copyright (c) 2014 ShareThis. All rights reserved.
//

#import "SZNetworkImageProvider.h"
#import "UIDevice+VersionCheck.h"

//Convenience class to provide social network images
//Given the class hierarchies for share and auth screens, this is cleaner
//than class clusters for all those classes
@implementation SZNetworkImageProvider


+ (UIImage *)facebookSelectNetworkImage:(BOOL)enabled {
    UIImage *retVal;
    
    if(enabled) {
        if([[UIDevice currentDevice] systemMajorVersion] < 7) {
            retVal = [UIImage imageNamed:@"socialize-selectnetwork-facebook-icon.png"];
        }
        else {
            retVal = [UIImage imageNamed:@"socialize-selectnetwork-facebook-icon-ios7.png"];
        }
    }
    else {
        if([[UIDevice currentDevice] systemMajorVersion] < 7) {
            retVal = [UIImage imageNamed:@"socialize-selectnetwork-facebook-dis-icon.png"];
        }
        else {
            retVal = [UIImage imageNamed:@"socialize-selectnetwork-facebook-dis-icon-ios7.png"];
        }
    }
    
    return retVal;
}

+ (UIImage *)twitterSelectNetworkImage:(BOOL)enabled {
    UIImage *retVal;
    
    if(enabled) {
        if([[UIDevice currentDevice] systemMajorVersion] < 7) {
            retVal = [UIImage imageNamed:@"socialize-selectnetwork-twitter-icon.png"];
        }
        else {
            retVal = [UIImage imageNamed:@"socialize-selectnetwork-twitter-icon-ios7.png"];
        }
    }
    else {
        if([[UIDevice currentDevice] systemMajorVersion] < 7) {
            retVal = [UIImage imageNamed:@"socialize-selectnetwork-twitter-dis-icon.png"];
        }
        else {
            retVal = [UIImage imageNamed:@"socialize-selectnetwork-twitter-dis-icon-ios7.png"];
        }
    }

    return retVal;
}

//+ (UIImage *)pinterestSelectNetworkImage:(BOOL)enabled {
//    
//}
//
//+ (UIImage *)facebookCommentImage:(BOOL)enabled {
//    
//}
//
//+ (UIImage *)twitterCommentImage:(BOOL)enabled {
//    
//}

@end
