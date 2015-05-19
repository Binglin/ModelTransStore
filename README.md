# ModelTransStore
simple transform dictionary to model,and save model to sqlite
a simple tranform model tool  like JSONModel

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@interface APPInfo : NSObject

@property (nonatomic, strong) NSNumber<UniqueKey>   * version;
@property (nonatomic, assign) BOOL        hasNew;
@property (nonatomic, strong) NSString    *appName;

@end
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//anilyze the model with dic
NSDictionary *appDicNormal = @{@"version":@(1.0),
                               @"appName":@"name of app",
                               @"hasNew":@(0)};
APPInfo *appInfo = [[APPInfo alloc] initTransformWithDic:appDicNormal];

 NSLog(@"version %@,has new %@, appname %@",appInfo.version,(appInfo.hasNew ? @"YES":@"NO"),appInfo.appName);
 //version 1,has new NO, appname weibo
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
 
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 insert appInfo to sqlite
 just call 
 and the model will be saved to a table named NSStringFromClass([appInfo class])
 
 [appInfo insertSelf];
 
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
 
 if you want to insert if not exist and update if exist
 at this time , you should define an unique key like ,
 assume that the version should be the unique value key
 
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 @property (nonatomic, strong) NSNumber<UniqueKey>   * version;
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
 or override the fuction like this 
 
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 +(NSString *)unique_key{
    return @"version";
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

at this time,just call like this ,


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
[appInfo uniqueInsert];
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
