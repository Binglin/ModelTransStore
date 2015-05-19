//
//  RuntimeProperty.m
//
//  Created by 郑林琴 on 15/5/13.
//  Copyright (c) 2015年  All rights reserved.
//

#import "RuntimeProperty.h"
#import "macro.h"
#import "NSObject+BlPersistentStore.h"


@implementation RuntimeProperty

- (instancetype)initWithProperty_t:(objc_property_t)property_t class:(Class)className{
    RuntimeProperty *runtime_property = [RuntimeProperty new];

    //name of property
    const char *property_name = property_getName(property_t);

    runtime_property.name = @(property_name);
    
    //encode analyze
    unsigned int outatri;
    objc_property_attribute_t *attribute_t = property_copyAttributeList(property_t, &outatri);
    onExits(FREE_ATTRIBUTE_T){
        free(attribute_t);
    };
    
    objc_property_attribute_t attribute_t_0 = attribute_t[0];
    const char *attr_value = attribute_t_0.value;
    NSString *atri_0_name_str = @(attr_value);
    if ([[atri_0_name_str substringToIndex:1] isEqualToString:@"@"]) {
        runtime_property.encodeType = BIEncodeType_Object;
        if (atri_0_name_str.length > 1) {
            //NSObject or subClass
            NSString *property_encode = [atri_0_name_str substringWithRange:NSMakeRange(2, atri_0_name_str.length - 3)];
            NSArray *components = [property_encode componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
            
            //属性是否忽略
            if ([components containsObject:@"Ignore"]) {
                return nil;
            }
            //值为唯一的property
            else if ([components containsObject:@"UniqueKey"]){
                
                [className setUnique_key:runtime_property.name];
                
            }
            
            runtime_property.propertyClass = NSClassFromString(components[0]);

            
            //寻找要转化成的类型的class 比如NSArray<DestinationClass>
            for (int i = 1; i < components.count ; i ++ ) {
                NSString *componenti_i = components[i];
                if (componenti_i.length) {
                    runtime_property.destinationClass = NSClassFromString(componenti_i);
                    if (runtime_property.destinationClass) {
                        break;
                    }
                }
            }
//            printf("property_encode %s\n",property_encode.UTF8String);
        }
        
        
        runtime_property.isPrimitive = NO;
    }else{
        runtime_property.isPrimitive = YES;
//        printf("primitive type %c\n",attr_value[0]);
        runtime_property.encodeType  = attr_value[0];
    }
    return runtime_property;
}

+ (NSArray *)getRuntimePropertyOfClass:(Class)className{
    unsigned int outCount ;

    if ([className conformsToProtocol:@protocol(TableNameReplace)]) {
        [className setTableName:[NSString stringWithFormat:@"Replace_%@",NSStringFromClass(className)]];
    }else{
        [className setTableName:NSStringFromClass(className)];
    }
    
    if (className == [NSObject class]) {
        return nil;
    }
    NSMutableArray *propertiesArr = [NSMutableArray new];
    
    
    NSArray *intValues = @[@(BIEncodeType_Char),@(BIEncodeType_UChar),@(BIEncodeType_BOOL),@(BIEncodeType_Short),
                           @(BIEncodeType_UShort),@(BIEncodeType_Int),@(BIEncodeType_UInt),@(BIEncodeType_Long),
                           @(BIEncodeType_ULong),@(BIEncodeType_long_long),@(BIEncodeType_ULong_long)];
    
    NSArray *textValues = @[@(BIEncodeType_Class),@(BIEncodeType_SEL)];
    
    NSArray *RealValues = @[@(BIEncodeType_Float),@(BIEncodeType_Double)];

    
    while (className != [NSObject class]) {
        objc_property_t *properties  =  class_copyPropertyList(className, &outCount);
        onExits(freeProperties){
            free(properties);
        };
        
//        printf("~~~~~~~~~~~~~~className = %s ~~~~~~~~~~~~\n",class_getName(className));
        for (int i = 0; i < outCount; i ++ ) {
            RuntimeProperty *rumtime_ = [[RuntimeProperty alloc ] initWithProperty_t:properties[i] class:className];
            if (rumtime_) {
                [propertiesArr addObject:rumtime_];
                
                if ([rumtime_.propertyClass isSubclassOfClass:[NSArray class]] ||
                    [rumtime_.propertyClass isSubclassOfClass:[NSDictionary class]]) {
                    rumtime_.isFoundation = YES;
                }
                
                if (rumtime_.propertyClass == [NSString class]) {
                    
                    rumtime_.sqliteType = SQLiteDataType_TEXT;
                    continue;
                    
                }
                else if (rumtime_.propertyClass == [NSNumber class]){
                    
                    rumtime_.sqliteType = SQLiteDataType_REAL;
                    continue;
                    
                }
                else if ([rumtime_.propertyClass isSubclassOfClass:[NSArray class]]){
                    
                    rumtime_.sqliteType = (rumtime_.destinationClass == nil) ? SQLiteDataType_Array : SQLiteDataType_ModelArray;
                    
                }
                //![rumtime_.propertyClass isSubclassOfClass:[NSArray class]]
                else if (rumtime_.propertyClass){
                    
                    rumtime_.sqliteType = SQLiteDataType_Model;
                    
                }
//#warning - TODO NSDictionary in property 
                
                if ([intValues containsObject:@(rumtime_.encodeType)]) {
                    rumtime_.sqliteType = SQLiteDataType_INTEGER;
                }else if ([textValues containsObject:@(rumtime_.encodeType)]){
                    rumtime_.sqliteType = SQLiteDataType_TEXT;
                }else if ([RealValues containsObject:@(rumtime_.encodeType)]){
                    rumtime_.sqliteType = SQLiteDataType_REAL;
                }
            }
        }
        className = [className superclass];
        
    }
    
    return propertiesArr;
}

@end
