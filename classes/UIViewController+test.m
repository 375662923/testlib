//
//  UIViewController+test.m
//  KeyProcedure
//
//  Created by idu on 2017/5/31.
//  Copyright © 2017年 smartinspection.cn. All rights reserved.
//

#import "UIViewController+test.h"
#import <objc/message.h>
@implementation UIViewController (test)

+ (void)load {
  Method addobject = class_getInstanceMethod(self, @selector(viewDidLoad));
  Method logAddobject = class_getInstanceMethod(self, @selector(logAddObject));
  method_exchangeImplementations(addobject, logAddobject);
}

- (void)logAddObject {
  [self logAddObject];
//  NSLog(@"controller%s,%d",  __FUNCTION__, __LINE__);
  NSLog(@"iduTest%@", self.class);
}

@end
