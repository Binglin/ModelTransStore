//
//  ViewController.m
//  ModelTransStorage
//
//  Created by 郑林琴 on 15/5/19.
//  Copyright (c) 2015年 郑林琴. All rights reserved.
//

#import "ViewController.h"
#import "APPInfo.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self tranformDictionaryToModel];
}

- (void)tranformDictionaryToModel{
    
    /**APPInfo dic*/
    NSDictionary *appDicNormal_ = @{@"version":@(1.0),
                                   @"appName":@"weibo",
                                   @"hasNew":@(0),
                                   @"ads":@[
                                            @{@"id":@"1",
                                              @"name":@"百度",
                                              @"url":@"http://baidu.com/",
                                              },
                                            @{@"id":@"2",
                                              @"name":@"xixi",
                                              @"url":@"http://baidu.com/",
                                              }
                                            ],
                                   @"company":@{@"name":@"company name"}
                                   };
  
#define kUniqueSave
    /*** 解析dic to model ～～～～～～～～ APPInfo 中包含其它model */
    APPInfo *appInfo_ = [[APPInfo alloc] initTransformWithDic:appDicNormal_];
    NSDictionary *appDicNormal = @{@"version":@(1.0),
                                   @"appName":@"name of app",
                                   @"hasNew":@(0)};
    APPInfo *appInfo = [[APPInfo alloc] initTransformWithDic:appDicNormal_];
    
    NSLog(@"version %@,has new %@, appname %@",appInfo.version,(appInfo.hasNew ? @"YES":@"NO"),appInfo.appName);

    
    /*** model to dic*/
    NSDictionary *modelDic = [appInfo toDictionary];
    NSLog(@"\n\nmodel to dic is \n%@",modelDic);
    
#ifndef kUniqueSave
    /***  model save in sqlite*/
    [appInfo insertSelf];
    
#else
    /***  model unique save in sqlite,需要属性值唯一的属性<UniqueKey>*/
    [appInfo uniqueInsert];
    
#endif
    
    /***  获取所有APPInfo类的数据*/
    NSArray *fetch  = [APPInfo fetchAll];;
    NSLog(@"\n\n从数据库中获取所有APPInfo \n%@",[fetch firstObject]);
}

@end
