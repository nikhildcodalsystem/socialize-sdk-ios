//
//  SocializeViewService.m
//  SocializeSDK
//
//  Created by Fawad Haider on 6/30/11.
//  Copyright 2011 Socialize, Inc. All rights reserved.
//

#import "SocializeViewService.h"

#define VIEW_METHOD @"view/"
#define ENTRY_KEY @"key"
#define ENTITY_KEY @"entity"

@implementation SocializeViewService


-(void) dealloc
{
    [super dealloc];
}

-(Protocol *)ProtocolType
{
    return  @protocol(SocializeView);
}

-(void)createViewForEntity:(id<SocializeEntity>)entity longitude:(NSNumber*)lng latitude: (NSNumber*)lat{
    [self createViewForEntityKey:[entity key] longitude:lng latitude:lat];
}

-(void)createViewForEntityKey:(NSString*)key longitude:(NSNumber*)lng latitude: (NSNumber*)lat{
    
    if (key && [key length]){   
        NSMutableDictionary* entityParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:key, @"entity_key", nil];
        
        if (lng!= nil && lat != nil)
        {
            [entityParam setObject:lng forKey:@"lng"];
            [entityParam setObject:lat forKey:@"lat"];
        }
        
        NSArray *params = [NSArray arrayWithObject:entityParam];
        [self ExecutePostRequestAtEndPoint:VIEW_METHOD WithParams:params expectedResponseFormat:SocializeDictionaryWIthListAndErrors];
    }
}

@end
