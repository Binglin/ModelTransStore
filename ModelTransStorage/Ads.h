//
//  Ads.h
//
//  Created by 郑林琴 on 15/5/16.
//  Copyright (c) 2015年  All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RuntimeProperty.h"

@protocol ImagePiece <NSObject>
@end

@interface ImagePiece : NSObject

@property (nonatomic, strong) NSString *thumnail;
@property (nonatomic, strong) NSString *small;

@end







@interface SingleModel : NSObject

@property (nonatomic, strong) NSString *name;

@end



@protocol Ads <NSObject>
@end

@interface Ads : NSObject

@property (nonatomic, strong) NSNumber<UniqueKey> *id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSArray<ImagePiece>  *images;

@end
