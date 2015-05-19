//
//  macro.h
//
//  Created by 郑林琴 on 15/5/16.
//  Copyright (c) 2015年  All rights reserved.
//

#ifndef BLExampleWorkspace_macro_h
#define BLExampleWorkspace_macro_h


/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
// void(^block)(void)的指针是void(^*block)(void)
static void blockCleanUp(__strong void(^*block)(void)) {
    (*block)();
}

#define onExit\
__strong void(^block)(void) __attribute__((cleanup(blockCleanUp),unused))=^
#define onExits(blockName)\
__strong void(^blockName)(void) __attribute__((cleanup(blockCleanUp),unused))=^



#pragma mark - 
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#define macro_stringify_(A) #A
#define macro_stringify(A)  macro_stringify_(A)

#define macro_concat_(A,B)  A ## B
#define macro_concate(A,B)  macro_concat_(A,B)




#pragma mark -
/**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#define kPUID @"kPUID" //parent unique id
#define kCUID @"kCUID" //child  unique id

#endif



