//
//  SZSocialNetworkImageProvider.h
//  Socialize
//
//  Created by David Jedeikin on 1/13/14.
//  Copyright (c) 2014 ShareThis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SZNetworkImageProvider : NSObject

+ (UIImage *)facebookSelectNetworkImage:(BOOL)enabled;
+ (UIImage *)twitterSelectNetworkImage:(BOOL)enabled;
//+ (UIImage *)pinterestSelectNetworkImage:(BOOL)enabled;
//+ (UIImage *)facebookCommentImage:(BOOL)enabled;
//+ (UIImage *)twitterCommentImage:(BOOL)enabled;

@end
