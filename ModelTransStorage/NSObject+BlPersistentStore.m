//
//  NSObject+BlPersistentStore.m
//
//  Created by 郑林琴 on 15/5/16.
//  Copyright (c) 2015年  All rights reserved.
//

#import "NSObject+BlPersistentStore.h"
#import "RuntimeProperty.h"
#import <objc/runtime.h>
#import "macro.h"
#import <sqlite3.h>
#import "NSObject+BlModelTransform.h"
#import "NSArray+sqlite_store.h"




@implementation NSObject (BlPersistentStore)

+ (void)load{
    
    
}

+ (NSString *)unique_key{
    return objc_getAssociatedObject(self, @selector(unique_key));
}

+ (void)setUnique_key:(NSString *)unique_key{
    objc_setAssociatedObject(self, @selector(unique_key), unique_key, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (SQLiteDataType)unique_key_type{
    return [objc_getAssociatedObject(self, @selector(unique_key_type)) integerValue];
}

+ (void)setUnique_key_type:(SQLiteDataType)sqliteType{
    objc_setAssociatedObject(self, @selector(unique_key_type), @(sqliteType),
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (NSString *)tableName{
    return objc_getAssociatedObject(self, @selector(tableName));
}

+ (void)setTableName:(NSString *)tableName{
    if ([tableName caseInsensitiveCompare:@"ORDER"] == NSOrderedSame) {
        tableName = [NSString stringWithFormat:@"Replace_%@",tableName];
    }
   return objc_setAssociatedObject(self, @selector(tableName), tableName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (BOOL)tableExist{
    id obj = objc_getAssociatedObject(self, @selector(tableExist));
    if ([obj boolValue]) {
        return YES;
    }
    BOOL create = [[BISqlitePersistentStore persistentStore] createTableWithClass:[self class]];
    if (create) {
        [self setTableExist:create];
    }
    return create;
}

+ (void)setTableExist:(BOOL)tableExist{
    objc_setAssociatedObject(self, @selector(tableExist), @(tableExist), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)tableName{
    return [self.class tableName];
}

- (NSNumber *)kPUID_value{
    return objc_getAssociatedObject(self, @selector(kPUID_value));
}

- (void)setKPUID_value:(NSNumber *)kPUID_value{
    objc_setAssociatedObject(self, @selector(kPUID_value), kPUID_value, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


+ (NSDictionary *)propertiesSqliteType{
    id obj = objc_getAssociatedObject(self, @selector(propertiesSqliteType));
    if (obj) {
        return obj;
    }
    [self initializeConfig];
    return [self propertiesSqliteType];
}

+ (NSArray *)allProperties{
    id obj = objc_getAssociatedObject(self, @selector(allProperties));
    if (obj) {
        return obj;
    }
    [self initializeConfig];
    return [self allProperties];
}


+ (void)initializeConfig{
    NSArray *property_arr = [self BI_Properties];
    
    NSMutableArray *_all  = [NSMutableArray arrayWithCapacity:property_arr.count];
    NSMutableDictionary *sqliteTypeMap = [NSMutableDictionary dictionaryWithCapacity:property_arr.count];
    
    
    [property_arr enumerateObjectsUsingBlock:^(RuntimeProperty * runtime_p, NSUInteger idx, BOOL *stop) {
        
        [_all addObject:runtime_p.name];
        SQLiteDataType type = runtime_p.sqliteType;
        Class model_class;

        if (SQLiteDataType_Model == type) {
            model_class = runtime_p.propertyClass;
        }else if (SQLiteDataType_ModelArray == type){
            model_class = runtime_p.destinationClass;
        }
        [sqliteTypeMap setObject:model_class ? @[@(type),model_class]:@[@(type)] forKey:runtime_p.name];
    }];
    objc_setAssociatedObject(self, @selector(propertiesSqliteType), sqliteTypeMap, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, @selector(allProperties), _all, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)sqlitePath{
    NSArray *doucuments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[doucuments firstObject] stringByAppendingPathComponent:@"ecshopStore.sqlite"];
}


- (BOOL)insertSelf{
    return [self insertSelfWithParent:nil];
}

- (BOOL)updateSelf{
    return [self updateSelfWithParent:nil];
}

- (BOOL)insertSelfWithParent:(id)object{
    [[self class] tableExist];
    NSMutableArray *keys   = [NSMutableArray new];
    NSMutableArray *values = [NSMutableArray new];
    
    if (object) {
        NSString *parent_unique_key = [[object class] unique_key];
        if (parent_unique_key) {
            [keys addObject:kPUID];
            [values addObject:[object valueForKey:parent_unique_key]];
        }else{
            
        }
    }
    
    [self.BI_Properties enumerateObjectsUsingBlock:^(RuntimeProperty * property, NSUInteger idx, BOOL *stop) {
        
      
        id value = [self valueForKey:property.name];
        id insertFormate = [value insertFormate];
        
        if (insertFormate) {
            [keys addObject:property.name];
            [values addObject:insertFormate];
        }else{
            [value insertSelfWithParent:self];
        }
        /*
        if (dataType == SQLiteDataType_INTEGER || dataType == SQLiteDataType_REAL) {
            
            if (value) {
                [keys   addObject:property.name];
                [values addObject:value];
            }
            
        }else if (dataType == SQLiteDataType_TEXT){
            
            if (value) {
                [keys   addObject:property.name];
                [values addObject:[NSString stringWithFormat:@"'%@'",value]];
            }
            
        }else if (dataType == SQLiteDataType_Model){
            [value insertSelfWithParent:self];
            
        }else if (dataType == SQLiteDataType_ModelArray){
            
            for (id model_array_i in value) {
                [model_array_i insertSelfWithParent:self];
            }
        }*/
        
        
    }];
    
    if (keys.count) {
        
        NSString *insert = [NSString stringWithFormat:@"insert into %@(%@) values(%@)",[self tableName],[keys componentsJoinedByString:@","],[values componentsJoinedByString:@","]];
        return [[BISqlitePersistentStore persistentStore] exeSQL:insert];
    }
    return NO;
}

- (BOOL)uniqueInsert{
    if ([self isExistInTable]) {
        return [self updateSelf];
    }
    return [self insertSelf];
}


- (BOOL)updateSelfWithParent:(id)parentObj{
    [[self class] tableExist];
    NSMutableArray *setSQL = [NSMutableArray new];
    [[self.class BI_Properties] enumerateObjectsUsingBlock:^(RuntimeProperty * runProperty, NSUInteger idx, BOOL *stop) {
        
        SQLiteDataType sqlType = runProperty.sqliteType;
        
        NSString *key = runProperty.name;
        id value  = [self valueForKey:key];
        
//        id setSeg = [value updateFormateKey:key];
//        
//        if (setSeg) {
//            [setSQL addObject:setSeg];
//        }else{
//            [value updateSelfWithParent:self];
//        }
        
        if (sqlType == SQLiteDataType_INTEGER || sqlType == SQLiteDataType_REAL) {
            if (value) {
                [setSQL addObject:[NSString stringWithFormat:@"%@ = %@",key,value]];
            }
        }else if (sqlType == SQLiteDataType_TEXT){
            if (value) {
                [setSQL addObject:[NSString stringWithFormat:@"%@ = '%@'",key,value]];
            }
        }else if (sqlType == SQLiteDataType_Model){

            [value updateSelfWithParent:self];
            
        }
        else if (sqlType == SQLiteDataType_ModelArray){
            
            for (id object_i in [self valueForKey:key]) {
                [object_i updateSelfWithParent:self];
            }
            
        }
    }];
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE %@ SET %@ ",[self tableName],[setSQL componentsJoinedByString:@","]];
    
    NSString *unique_key ;
    NSString *unique_key_value;
    
    //更新model中的model
    if (parentObj) {
        unique_key = kPUID;
        unique_key_value = [parentObj valueForKey:[[parentObj class] unique_key]];
    }
    //更新自己s
    else{
        NSString *unique_key = [[self class] unique_key];
        unique_key_value = [self valueForKey:unique_key];
    }
    
    updateSQL = [updateSQL stringByAppendingFormat:@"where %@ = %@",unique_key,unique_key_value];
    return [[BISqlitePersistentStore persistentStore] exeSQL:updateSQL];
}


- (BOOL)createTable{
    return [[BISqlitePersistentStore persistentStore] createTableWithClass:[self class]];
}

- (BOOL)isTableExist{
    return [[BISqlitePersistentStore persistentStore] isExistTable:[self tableName]];
}

- (BOOL)isExistInTable{
    [self BI_Properties];
    NSString *unique_key = [[self class] unique_key];
    NSAssert(unique_key != nil, @"检查在表中的唯一性需要指定unique_key");
    NSString *select = [NSString stringWithFormat:@"select count(*) from %@ where %@ = %@",[self tableName],[self class].unique_key,[self valueForKey:[[self class] unique_key]]];
    sqlite3_stmt *statement;
    if ([[BISqlitePersistentStore persistentStore] selectSQL:select SQLstatement:&statement]) {
        if ( sqlite3_step(statement) == SQLITE_ROW) {
            int count = sqlite3_column_int(statement, 0);
            return count ? YES : NO;
        }
    }
    return NO;
}


+ (NSArray *)fetchAll{
    [self BI_Properties];
    NSArray *all = [[BISqlitePersistentStore persistentStore] fetchTable:[self class] withProperties:nil WithCondition:nil];
    return all;
}

@end


