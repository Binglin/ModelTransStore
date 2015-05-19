//
//  APPInfo.h
//
//  Created by 郑林琴 on 15/5/16.
//  Copyright (c) 2015年  All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+BlPersistentStore.h"
#import "NSObject+BlModelTransform.h"
#import "RuntimeProperty.h"
#import "Ads.h"

@interface BaseModel : NSObject

@property (nonatomic, strong) NSString *baseProperty;

@end

@interface APPInfo : NSObject

@property (nonatomic, strong) NSNumber<UniqueKey>   * version;
@property (nonatomic, assign) BOOL        hasNew;
@property (nonatomic, strong) NSString    *appName;
@property (nonatomic, strong) NSArray<Ads>     *ads;
@property (nonatomic, strong) SingleModel *model;

@end
