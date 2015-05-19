//
//  NSObject+BlModelTransform.m
//
//  Created by 郑林琴 on 15/5/16.
//  Copyright (c) 2015年  All rights reserved.
//

#import "NSObject+BlModelTransform.h"
#import "RuntimeProperty.h"

static NSNumberFormatter *_numberTransformFormatter = nil;

@implementation NSObject (BlModelTransform)

+ (BOOL)needModelTransform{
    return YES;
}

+ (void)load{
    _numberTransformFormatter = [NSNumberFormatter new];
}

+ (NSArray *)BI_Properties{
    id object = objc_getAssociatedObject(self, @selector(BI_Properties));
    if (object) {
        return object;
    }
    NSArray *properties = [RuntimeProperty getRuntimePropertyOfClass:[self class]];
    objc_setAssociatedObject(self, @selector(BI_Properties), properties, OBJC_ASSOCIATION_COPY_NONATOMIC);
    return [self BI_Properties];
}

- (NSArray *)BI_Properties{
    return [self.class BI_Properties];
}

- (instancetype)initTransformWithDic:(NSDictionary *)dic{
    if (self = [self init]) {
        NSArray *rumtimeProperty = self.BI_Properties;
        [rumtimeProperty enumerateObjectsUsingBlock:^(RuntimeProperty* property, NSUInteger idx, BOOL *stop) {
            
            //dic中属性名对应的值
            id VALUE = dic[property.name];

            SQLiteDataType propertySQLType = property.sqliteType;
            
            if (propertySQLType == SQLiteDataType_INTEGER || propertySQLType == SQLiteDataType_REAL) {
                
                if ([VALUE isKindOfClass:[NSString class]]) {
                    NSNumber *number_ = [_numberTransformFormatter numberFromString:VALUE];
                    if (number_) {
                        VALUE = number_;
                    }
                }
                
            }
            else if (propertySQLType == SQLiteDataType_TEXT){
                
                if ([VALUE isKindOfClass:[NSNumber class]]) {
                    VALUE = [VALUE stringValue];
                }
                
            }else if (propertySQLType == SQLiteDataType_ModelArray){
                
                NSMutableArray *array = [NSMutableArray new];
                for (NSDictionary *dic_in_arr in (NSArray*)VALUE) {
                    [array addObject: [[property.destinationClass alloc] initTransformWithDic:dic_in_arr]];
                }
                VALUE = array;
                
            }else if (propertySQLType == SQLiteDataType_Model){
                
                VALUE = [[property.propertyClass alloc] initTransformWithDic:VALUE];
                
            }
            [self setValue:VALUE forKey:property.name];
        }];
    }
    return self;
}


+ (NSDictionary *)keyMapping{
    return nil;
}


- (NSDictionary *)toDictionary{
    NSArray *runtimeProperty = [self.class BI_Properties];
    NSMutableDictionary *dic_model = [NSMutableDictionary dictionaryWithCapacity:runtimeProperty.count];
    [runtimeProperty enumerateObjectsUsingBlock:^(RuntimeProperty* property, NSUInteger idx, BOOL *stop) {
        
        SQLiteDataType sqliteType = property.sqliteType;
        
        NSString *property_name = property.name;
        
        //SQLiteDataType_INTEGER SQLiteDataType_TEXT Dictionary
        id value = [self valueForKey:property_name];
        
        //model数组
        if (sqliteType == SQLiteDataType_ModelArray) {
            
            NSMutableArray *array = [NSMutableArray new];
            
            for (id object in [self valueForKey:property_name]) {
                [array addObject:[object toDictionary]];
            }
            value = array;
            
        }
        //model
        else if (sqliteType == SQLiteDataType_Model){
            
            value = [value toDictionary];
            
        }
        
        [dic_model setObject:value forKey:property_name];
        
    }];
    return dic_model;
}

@end
