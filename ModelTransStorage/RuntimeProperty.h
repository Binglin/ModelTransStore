//
//  RuntimeProperty.h
//
//  Created by 郑林琴 on 15/5/13.
//  Copyright (c) 2015年  All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef enum : NSUInteger {
    BIEncodeType_Object = '@',// id
    BIEncodeType_Class  = '#',//#
    BIEncodeType_SEL    = ':',//:
    BIEncodeType_Char   = 'c',//c
    BIEncodeType_UChar  = 'C',//C
    BIEncodeType_Chars  = '*',//C
    
    BIEncodeType_BOOL   = 'B',//B
    
    BIEncodeType_Short  = 's',//s
    BIEncodeType_UShort = 'S',//S
    BIEncodeType_Int    = 'i',//i
    BIEncodeType_UInt   = 'I',//I
    BIEncodeType_Long   = 'l',//l
    BIEncodeType_ULong  = 'L',//L
    BIEncodeType_long_long  ='q',//q
    BIEncodeType_ULong_long ='Q',//Q
    BIEncodeType_Float  ='f',//f
    BIEncodeType_Double ='d',//d
} BIEncodeType;

typedef enum : NSUInteger {
    SQLiteDataType_NULL,
    SQLiteDataType_TEXT,
    SQLiteDataType_INTEGER,
    SQLiteDataType_REAL,
    SQLiteDataType_BLOB,
    
    //model中包含另一种model时
    SQLiteDataType_Model,
    SQLiteDataType_ModelArray,
    SQLiteDataType_Array,
    SQLiteDataType_Dictionary
} SQLiteDataType;

struct store_property_attri {
    BIEncodeType    encodeType;
    SQLiteDataType  sqliteType;
    BOOL            isPrimitiveType;
    Class           propertyClass;
};


typedef void(^UniqueKeyBlock)(NSString *name);

/**
 *  忽略某个property
 */
@protocol Ignore <NSObject>
@end


/**
 *  某个property为model的唯一 供数据库存储用,解析model时自动设置到unique_key中
 *  UniqueKey 需要为NSNumber类型 非对象，则复写unique_key类方法
 */
@protocol UniqueKey <NSObject>
@end


/**
 *  table名字替换
 */
@protocol TableNameReplace <NSObject>

@end

@interface RuntimeProperty : NSObject

+ (NSArray *)getRuntimePropertyOfClass:(Class)className;

@property (nonatomic, strong)  NSString   *name;

@property (nonatomic, assign)  BIEncodeType     encodeType;
@property (nonatomic, assign)  SQLiteDataType   sqliteType;
@property (nonatomic, assign)  BOOL       isPrimitive;

//propertyClass 是否是NSArray 或者是NSDictionary 是则为YES
@property (nonatomic, assign)  BOOL       isFoundation;

@property (nonatomic, assign)  BOOL       isIgnore;
@property (nonatomic, assign)  Class      propertyClass;//属性类型
@property (nonatomic, assign)  Class      destinationClass;//属性中的protocol和类名一样的class



@end
