//
//  NSObject+BlPersistentStore.h
//
//  Created by 郑林琴 on 15/5/16.
//  Copyright (c) 2015年  All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BISqlitePersistentStore.h"
#import "RuntimeProperty.h"

@interface NSObject (BlPersistentStore)

/** 数据唯一字段 默认为INTERGER*/
+ (NSString *)unique_key;
+ (void)setUnique_key:(NSString *)unique_key;


///** 某个属性中为model的*/
+ (SQLiteDataType)unique_key_type;
+ (void)setUnique_key_type:(SQLiteDataType)sqliteType;


/*表名设置*/
+ (NSString *)tableName;
+ (void)setTableName:(NSString *)tableName;

+ (BOOL)tableExist;
+ (void)setTableExist:(BOOL)tableExist;

/** key为属性name value为@(SQLiteDataType)*/
+ (NSDictionary *)propertiesSqliteType;

/** 所有属性name数组*/
+ (NSArray *)allProperties;


/*父类unique_key的值*/
@property (nonatomic, strong) NSNumber *kPUID_value;


/**
 *  是否需要数据库存储
 */
//+ (BOOL)needPersistentStore;
- (BOOL)createTable;
- (BOOL)isTableExist;

- (BOOL)insertSelf;
- (BOOL)updateSelf;
- (BOOL)insertSelfWithParent:(id)object;
- (BOOL)updateSelfWithParent:(id)parentObj;

/***  存在则更新 不存在则update*/
- (BOOL)uniqueInsert;

//自身数据是否已存在table中
- (BOOL)isExistInTable;
+ (NSArray *)fetchAll;

@end

