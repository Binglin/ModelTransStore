//
//  NSArray+sqlite_store.m
//
//  Created by 郑林琴 on 15/5/18.
//

#import "NSArray+sqlite_store.h"
#import "BIModelExtension.h"


@implementation NSObject (insert_Formate)

- (NSString *)insertFormate{
    return nil;
}

- (NSString *)updateFormateKey:(NSString *)key{
    return nil;
}

@end






@implementation NSArray (sqlite_store)

- (BOOL)insertSelfWithParent:(id)object{
    BOOL insert = YES;
    for (id object_i in self) {
        insert = insert && [object_i insertSelfWithParent:object];
    }
    return insert;
}

- (BOOL)updateSelfWithParent:(id)parentObj{
    BOOL update = YES;
    for (id object_i in self) {
        update = update && [object_i updateSelfWithParent:parentObj];
    }
    return update;
}

@end




@implementation NSString (insert_Formate)

- (NSString *)insertFormate{
    return [NSString stringWithFormat:@"'%@'",self];
}

- (NSString *)updateFormateKey:(NSString *)key{
    return [NSString stringWithFormat:@"%@ = '%@'",key,self];
}

@end



@implementation NSNumber (insert_Formate)

- (NSNumber *)insertFormate{
    return self;
}

@end