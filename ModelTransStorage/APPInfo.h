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

@class Company;


@protocol Ads <NSObject>
@end
@protocol ImagePiece <NSObject>
@end

@interface APPInfo : NSObject

@property (nonatomic, strong) NSNumber<UniqueKey>   * version;
@property (nonatomic, assign) BOOL                  hasNew;
@property (nonatomic, strong) NSString              *appName;
@property (nonatomic, strong) NSArray<Ads>          *ads;
@property (nonatomic, strong) Company               *company;

@end


@interface ImagePiece : NSObject

@property (nonatomic, strong) NSString *thumnail;
@property (nonatomic, strong) NSString *small;

@end


@interface Company : NSObject

@property (nonatomic, strong) NSString *name;

@end


@interface Ads : NSObject

@property (nonatomic, strong) NSNumber<UniqueKey> *id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
//@property (nonatomic, strong) NSArray<ImagePiece>  *images;

@end

