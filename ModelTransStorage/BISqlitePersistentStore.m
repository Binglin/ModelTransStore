//
//  BISqlitePersistentStore.m
//
//  Created by 郑林琴 on 15/5/17.
//  Copyright (c) 2015年  All rights reserved.
//

#import "BISqlitePersistentStore.h"
#import "NSObject+BlModelTransform.h"
#import "NSObject+BlPersistentStore.h"
#import <objc/runtime.h>
#import "RuntimeProperty.h"
#import "macro.h"


@interface BISqlitePersistentStore ()

@property (nonatomic, strong) NSMutableArray *tableCreated;


@end

@implementation BISqlitePersistentStore

- (instancetype)initWithPath:(NSString *)path{
    if (self = [super init]) {
        self.sqlitePath = path;
        self.tableCreated = [NSMutableArray new];
        [self open];
    }
    return self;
}

- (BOOL)open{
    //open会自动创建ecshopStore.sqlite文件
    if (sqlite3_open([[self sqlitePath] UTF8String], &_db) != SQLITE_OK) {
        const char *erroreMessage = sqlite3_errmsg(_db);
        sqlite3_close(_db);
//        NSLog(@"打开数据库失败 %s",erroreMessage);
        return NO;
    }
    self.isOpen = YES;
    return YES;
}

#pragma mark -
- (BOOL)isExistTable:(NSString *)tableName{
    BOOL isExist = NO;
    NSString *checkExist  = [NSString stringWithFormat:@"PRAGMA table_info(%@)",tableName];
    sqlite3_stmt *isExistStat ;
    if ([self selectSQL:checkExist SQLstatement:&isExistStat]) {
        if (sqlite3_step(isExistStat) == SQLITE_ROW) {
            isExist = YES;
        }else{
//            NSLog(@"check table exist failed");
        }
    }
    sqlite3_finalize(isExistStat);
//    NSLog(@"%s %@ %@",__func__,tableName, isExist ? @"YES":@"NO");
    return isExist;
}

- (BOOL)createTableWithClass:(Class)className{
    return [self createTableWithClass:className parent_key:nil];
}

- (BOOL)createTableWithClass:(Class)className parent_key:(NSString *)parentKey{
    
    NSAssert(className != nil, @"createTableWithClass className not nil");
    
    NSDictionary *SQLiteTypeMap = @{@(SQLiteDataType_INTEGER):@"INTEGER",
                                    @(SQLiteDataType_TEXT):@"TEXT",
                                    @(SQLiteDataType_REAL):@"REAL"};
    
    NSMutableArray *keysTOCreate = [NSMutableArray new];
    
    if (parentKey) {
        [keysTOCreate addObject:[NSString stringWithFormat:@"%@ INTERGER",kPUID]];
    }
    
    [[className BI_Properties] enumerateObjectsUsingBlock:^(RuntimeProperty * runtimeProperty, NSUInteger idx, BOOL *stop) {
        
        SQLiteDataType sqliteType = runtimeProperty.sqliteType;
        NSString *propertyType = SQLiteTypeMap[@(runtimeProperty.sqliteType)];
        
        if (propertyType) {
            
            [keysTOCreate addObject:[NSString stringWithFormat:@"%@ %@",runtimeProperty.name, propertyType]];
        }
        else if (SQLiteDataType_Model == sqliteType ){
            
            [self createTableWithClass:runtimeProperty.propertyClass parent_key:[className unique_key]];
            
        }else if (SQLiteDataType_ModelArray == sqliteType){
            
            [self createTableWithClass:runtimeProperty.destinationClass parent_key:[className unique_key]];
            
        }
    }];
    
    NSMutableString *createTable  ;
    if (keysTOCreate.count) {
        
        NSString *tableName = [className tableName];
        
        if (NO == [self isExistTable:tableName]) {
            createTable = [NSMutableString stringWithFormat:@"create table if not exists %@(%@)",tableName,[keysTOCreate componentsJoinedByString:@","]];
        }else{
            return YES;
        }
    }else{
        NSLog(@"create table failed: 无法获取model的属性");
        return NO;
    }
    return [self exeSQL:createTable];
}


#pragma mark -
- (BOOL)exeSQL:(NSString *)SQL{
    if (SQL == nil) {
        NSLog(@"%@",@"nil sql sentence");
        return NO;
    }
    char *err;
    if (sqlite3_exec(_db, [SQL UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        NSLog(@"exeSQL fail %s ~~~~~~~~ %@",sqlite3_errmsg(_db),SQL);
        return NO;
    }
    return YES;
}

- (BOOL)selectSQL:(NSString *)SQL SQLstatement:(sqlite3_stmt **)statement{
    const char *pzTail;
    if (sqlite3_prepare_v2(_db, [SQL UTF8String], -1, statement, &pzTail) == SQLITE_OK) {
        return YES;
    }
    NSLog(@"selectSQL fail %s ~~~~~~~~ %@",sqlite3_errmsg(_db),SQL);
    
    return NO;
}
//
//- (BOOL)fetchTable:(Class)className WithCondition:(NSString *)condition{
//    NSString 
//    [[className BI_Properties] enumerateObjectsUsingBlock:^(RuntimeProperty * runtimeProperty, NSUInteger idx, BOOL *stop) {
//        
//    }];
//}

- (NSArray *)fetchTable:(Class )className withProperties:(NSArray *)properties WithCondition:(NSString *)condition{
    NSString *propertyToFetch = @"*";
    if ([properties count]) {
        propertyToFetch = [properties componentsJoinedByString:@","];
    }
    NSString *SQL = [NSString stringWithFormat:@"SELECT %@ FROM %@ ",propertyToFetch, [className tableName]];
    if (condition) {
        SQL = [SQL stringByAppendingString:condition];
    }
    return [self exeuteFetch:SQL class:className withProperties:properties];
}

- (NSArray *)fetchTable:(Class)className withProperties:(NSArray *)properties parent:(id)parent{
    NSString *propertyToFetch = @"*";
    if ([properties count]) {
        propertyToFetch = [properties componentsJoinedByString:@","];
    }
    NSString *SQL = [NSString stringWithFormat:@"SELECT %@ FROM %@ ",propertyToFetch, [className tableName]];
    if (parent) {
        NSString *condition ;
        if (nil == [className unique_key]) {
            condition = [NSString stringWithFormat:@"where %@ ＝ %@",kPUID,[parent kPUID_value]];
        }else{
            condition = [NSString stringWithFormat:@"where %@ ＝ %@",[className unique_key],[parent valueForKey:[[parent class] unique_key]]];
        }
    }
    return [self exeuteFetch:SQL class:className withProperties:properties];
}

- (NSArray *)exeuteFetch:(NSString *)SQL class:(Class)className withProperties:(NSArray *)properties{
    sqlite3_stmt *statement;
    BOOL isSuceed = [self selectSQL:SQL SQLstatement:&statement];
    if (isSuceed) {
        NSMutableArray *results = [NSMutableArray new];
        
        if (properties == nil) {
            NSMutableArray *kPUIDPlus = [NSMutableArray new];

            if (nil == [className unique_key]) {
                [kPUIDPlus addObject:kPUID];
            }
            [kPUIDPlus addObjectsFromArray:[className allProperties]];
            properties = kPUIDPlus;
        }
        
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            
            id models = [[className alloc] init];
            
            NSMutableArray *modelProperties = [NSMutableArray new];
            
            for (int i = 0; i < properties.count; i ++){
                
                NSString *propertyName = properties[i];
                
                //@[type,class]
                NSArray *sqliteTypeObject = [className propertiesSqliteType][propertyName];
                id sqlTypeObject = sqliteTypeObject[0];
                
                SQLiteDataType sqlType = [sqlTypeObject integerValue];
                
                if (sqlType == SQLiteDataType_TEXT)
                {
                    const char *text = (const char *)sqlite3_column_text(statement, i);
                    [models setValue:[NSString stringWithUTF8String:text] forKey:propertyName];
                    
                }else if (sqlType == SQLiteDataType_INTEGER){
                    
                    int integer = sqlite3_column_int(statement, i);
                    [models setValue:@(integer) forKey:propertyName];
                    
                }else if (sqlType == SQLiteDataType_REAL){
                    
                    double Double = sqlite3_column_double(statement, i);
                    [models setValue:@(Double) forKey:propertyName];
                    
                }else if (sqlType == SQLiteDataType_Model || SQLiteDataType_ModelArray == sqlType){
                    [modelProperties addObject:propertyName];
                }
            }
            
            for (NSString *propertyName in modelProperties) {
                
                NSArray *sqliteTypeObject = [className propertiesSqliteType][propertyName];
                id sqlTypeObject = sqliteTypeObject[0];
                SQLiteDataType sqlType = [sqlTypeObject integerValue];
                id subModel;
                if (SQLiteDataType_Model == sqlType){
                    subModel = [[self fetchTable:sqliteTypeObject[1] withProperties:nil parent:models] firstObject];
                }else if (SQLiteDataType_ModelArray == sqlType){
                    subModel = [self fetchTable:sqliteTypeObject[1] withProperties:nil parent:models];
                }
                if (subModel) {
                    [models setValue:subModel forKey:propertyName];
                }
            }
            
            [results addObject:models];
        }
        return results;
    }
    return nil;
}

@end

