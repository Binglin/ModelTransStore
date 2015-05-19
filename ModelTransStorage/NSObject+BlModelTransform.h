//
//  NSObject+BlModelTransform.h
//
//  Created by 郑林琴 on 15/5/16.
//  Copyright (c) 2015年  All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (BlModelTransform)

/***  是否需要模型转换*/
+ (BOOL)needModelTransform;

+ (NSArray *)BI_Properties;

@property (nonatomic, strong, readonly) NSArray *BI_Properties;

- (instancetype)initTransformWithDic:(NSDictionary *)dic;

+ (NSDictionary *)keyMapping;

- (NSDictionary *)toDictionary;

@end
