//
//  BISqlitePersistentStore.h
//
//  Created by 郑林琴 on 15/5/17.
//  Copyright (c) 2015年  All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface BISqlitePersistentStore : NSObject

- (instancetype)initWithPath:(NSString *)path;

@property (nonatomic, assign) sqlite3 *db;
@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, strong) NSString *sqlitePath;

/*~~~~~~~~~~~BOOL 返回操作是否成功~~~~~~~~~~~~~~~~~~~~*/

- (BOOL)isExistTable:(NSString *)tableName;
- (BOOL)createTableWithClass:(Class)className;

/***  除select外的语句*/
- (BOOL)exeSQL:(NSString *)SQL;

/***  select语句*/
- (BOOL)selectSQL:(NSString *)SQL SQLstatement:(sqlite3_stmt **)statement;

- (NSArray *)fetchTable:(Class )className
         withProperties:(NSArray *)properties
          WithCondition:(NSString *)condition;

- (NSArray *)fetchTable:(Class )className
         withProperties:(NSArray *)properties
                 parent:(id)object;

@end
