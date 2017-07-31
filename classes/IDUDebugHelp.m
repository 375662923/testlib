//
//  IDUDebugHelp.m
//  IDUDebug
//
//  Created by idu on 2017/5/27.
//  Copyright © 2017年 idu. All rights reserved.
//

#import "IDUDebugHelp.h"
#define VERSION 1
typedef enum
{
   GENERAL,SUPERVIEWS,SUBVIEWS,CONSTRAINS,TRACE,ABOUT
} TableType;
NSString *msgIDUDebugView=@"msgIDUDebugView";
NSString *msgIDUDebugRemoveView=@"msgIDUDebugRemoveView";
NSString *msgIDUDebugRemoveSubView=@"msgIDUDebugRemoveSubView";
NSString *msgIDUDebugAddSubView=@"msgIDUDebugAddSubView";
NSString *msgIDUDebugContraints=@"msgIDUDebugContraints";
NSString *msgIDUDebugShow=@"msgIDUDebugShow";
CGFloat version=0;
@implementation IDUDebugObject
+(instancetype)objectWithWeak:(id)o
{
    IDUDebugObject *obj=[[IDUDebugObject alloc] init];
    obj.object=o;
    return obj;
}


@end
@interface IDUDebugHelp()<UITableViewDelegate,UITableViewDataSource>
{
    TableType type;
    NSMutableArray *arrSuper;
    NSMutableArray *arrSub;
    BOOL bTouch;
    CGFloat left,top;
    CGRect originFrame;
    NSMutableArray* arrTrace;
    CGFloat viewTrackBorderWidth;
    UIColor* ViewTrackBorderColor;
    NSMutableArray *arrConstrains;
    NSMutableArray *arrStackView;
    NSMutableArray *arrGeneral;
    NSMutableArray *arrAbout;
    NSArray *arrLeft;
    BOOL bTrace;
}
@end
@implementation IDUDebugHelp

-(void)willMoveToWindow:(UIWindow *)newWindow
{
    if(newWindow!=nil)
    {
        bTouch=NO;
        bTrace=NO;
        self.clipsToBounds=YES;
        self.translatesAutoresizingMaskIntoConstraints=YES;
        self.layer.borderWidth=2;
        self.layer.borderColor=[UIColor blackColor].CGColor;
        _tableLeft.delegate=self;
        _tableLeft.dataSource=self;
        _tableRight.delegate=self;
        _tableRight.dataSource=self;
        _btnBack.hidden=YES;
        arrLeft=@[@"General",@"SuperViews",@"SubViews",@"Constrains",@"Network",@"About"];
        arrStackView=[[NSMutableArray alloc] initWithCapacity:30];
        arrGeneral=[[NSMutableArray alloc] initWithCapacity:30];
        arrAbout=[[NSMutableArray alloc] initWithCapacity:30];
        [arrAbout addObject:@"test"];
        [arrAbout addObject:@"idu"];
        [self initView:_viewHit Back:NO];
           }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
      
        [[NSNotificationCenter defaultCenter] postNotificationName:msgIDUDebugShow object:nil];
    }
}





- (IBAction)onClose:(id)sender
{
    if([[_btnClose titleForState:UIControlStateNormal] isEqualToString:@"Close"])
    {
        [self removeFromSuperview];
    }
    else if([[_btnClose titleForState:UIControlStateNormal] isEqualToString:@"Stop"])
    {
        if(bTrace &&  _viewHit)
        {
            _viewHit.layer.borderColor=ViewTrackBorderColor.CGColor;
            _viewHit.layer.borderWidth=viewTrackBorderWidth;
            bTrace=NO;
        }
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView==_tableLeft)
    {
        return ABOUT+1;
    }
    else if(tableView==_tableRight)
    {
        if(type==GENERAL)
        {
            return arrGeneral.count;
        }
        else if(type==SUPERVIEWS)
        {
            return arrSuper.count;
        }
        else if(type==SUBVIEWS)
        {
            return arrSub.count;
        }
        else if(type==CONSTRAINS)
        {
            return  arrConstrains.count;
        }
        else if(type==TRACE)
        {
            return  arrTrace.count;
        }
        else if(type==ABOUT)
        {
            return arrAbout.count;
        }
        else
        {
            return 0;
        }
    }
    else
    {
        return 0;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if(tableView==_tableLeft)
    {
        NSString *cellID=@"IDUDebugHelpLeftCell";
        cell=[tableView dequeueReusableCellWithIdentifier:cellID];
        if(cell==nil)
        {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        cell.textLabel.font=[UIFont systemFontOfSize:14];
        cell.textLabel.text=arrLeft[indexPath.row];
        return cell;
    }
    else
    {
        if(type==GENERAL)
        {
            cell=[self handleGeneralCell:indexPath];
        }
        else if(type==SUPERVIEWS)
        {
            cell=[self handleSuperViewsCell:indexPath];
        }
        else if(type==SUBVIEWS)
        {
            cell=[self handleSubViewsCell:indexPath];
        }
        else if(type==CONSTRAINS)
        {
            cell=[self handleConstrainsCell:indexPath];
        }
        else if(type==TRACE)
        {
            cell=[self handleTraceCell:indexPath];
        }
        else if(type==ABOUT)
        {
            cell=[self handleAboutCell:indexPath];
        }
        return cell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==_tableLeft)
    {
        type=(TableType)indexPath.row;
        [_tableRight reloadData];
        
    }
    else
    {
        if(type==SUPERVIEWS)
        {
            UIView *view=((IDUDebugObject*)arrSuper[indexPath.row]).object;
            if(view)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:msgIDUDebugView object:view];
                [self initView:view Back:NO];
            }
            else
            {
                return;
            }
        }
        else if(type==SUBVIEWS)
        {
            UIView *view=((IDUDebugObject*)arrSub[indexPath.row]).object;;
            if(view)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:msgIDUDebugView object:view];
                [self initView:view Back:NO];
            }
            else
            {
                
                return;
            }
        }
        else if(type==CONSTRAINS)
        {
          
            NSMutableDictionary* dic=[NSMutableDictionary dictionaryWithDictionary:arrConstrains[indexPath.row]];
            [dic setObject:[IDUDebugObject objectWithWeak:_viewHit] forKey:@"View"];
            [[NSNotificationCenter defaultCenter] postNotificationName:msgIDUDebugContraints object:dic];
        }
      else if(type==TRACE)
      {
        UIView *view=((IDUDebugObject*)arrSub[indexPath.row]).object;;
        if(view)
        {
          [[NSNotificationCenter defaultCenter] postNotificationName:msgIDUDebugView object:view];
          [self initView:view Back:NO];
        }
        else
        {
          
          return;
        }
      
      }else
        {
            return;
        }
        [self minimize];
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==_tableLeft)
    {
        return 44;
    }
    else
    {
        if(type==GENERAL)
        {
            return [self heightForGeneralCell:indexPath Width:tableView.bounds.size.width-2*tableView.separatorInset.left];
        }
        else if(type==SUPERVIEWS)
        {
            return [self heightForSuperCell:indexPath Width:tableView.bounds.size.width-2*tableView.separatorInset.left];
        }
        else if(type==SUBVIEWS)
        {
            return [self heightForSubCell:indexPath Width:tableView.bounds.size.width-2*tableView.separatorInset.left];
        }
        else if(type==CONSTRAINS)
        {
            return [self heightForConstrainsCell:indexPath Width:tableView.bounds.size.width-2*tableView.separatorInset.left];
        }
        else if(type==TRACE)
        {
            return [self heightForTraceCell:indexPath Width:tableView.bounds.size.width-2*tableView.separatorInset.left];
        }
        else if(type==ABOUT)
        {
            return [self heightForAboutCell:indexPath Width:tableView.bounds.size.width-2*tableView.separatorInset.left];
        }
        else
        {
            return 0;
        }
    }
}


-(void)expand:(UIButton*)btn
{
    [btn removeFromSuperview];
    [UIView animateWithDuration:0.2 animations:^{
        self.frame=originFrame;
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    bTouch=YES;
    UITouch *touch=[touches anyObject];
    CGPoint p=[touch locationInView:self];
    left=p.x;
    top=p.y;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!bTouch)
    {
        return;
    }
    UITouch *touch=[touches anyObject];
    CGPoint p=[touch locationInView:self.window];
    self.frame=CGRectMake(p.x-left, p.y-top, self.frame.size.width, self.frame.size.height);
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    bTouch=NO;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    bTouch=NO;
}



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if([keyPath isEqualToString:@"frame"])
    {
        CGRect oldFrame=[change[NSKeyValueChangeOldKey] CGRectValue];
        CGRect newFrame=[change[NSKeyValueChangeNewKey] CGRectValue];
        if(CGRectEqualToRect(oldFrame, newFrame))
        {
            return;
        }
        [arrTrace addObject:@{
                             @"Key":@"Frame Change",
                             @"Time":[self currentDate],
                             @"OldValue":[NSString stringWithFormat:@"(l:%0.1lf t:%0.1lf w:%0.1lf h:%0.1lf)",oldFrame.origin.x,oldFrame.origin.y,oldFrame.size.width,oldFrame.size.height],
                             @"NewValue":[NSString stringWithFormat:@"(l:%0.1lf t:%0.1lf w:%0.1lf h:%0.1lf)",newFrame.origin.x,newFrame.origin.y,newFrame.size.width,newFrame.size.height]
                              }];
    }
    else if([keyPath isEqualToString:@"center"])
    {
        CGPoint oldCenter=[change[NSKeyValueChangeOldKey] CGPointValue];
        CGPoint newCenter=[change[NSKeyValueChangeNewKey] CGPointValue];
        if(CGPointEqualToPoint(oldCenter, newCenter))
        {
            return;
        }
        [arrTrace addObject:@{
                              @"Key":@"Center Change",
                              @"Time":[self currentDate],
                              @"OldValue":[NSString stringWithFormat:@"(x:%0.1lf y:%0.1lf)",oldCenter.x,oldCenter.y],
                              @"NewValue":[NSString stringWithFormat:@"(x:%0.1lf y:%0.1lf)",newCenter.x,newCenter.y]
                              }];
    }
    else if([keyPath isEqualToString:@"superview.frame"])
    {
        CGRect oldFrame=[change[NSKeyValueChangeOldKey] CGRectValue];
        CGRect newFrame=[change[NSKeyValueChangeNewKey] CGRectValue];
        if(CGRectEqualToRect(oldFrame, newFrame))
        {
            return;
        }
        [arrTrace addObject:@{
                              @"Key":@"Superview Frame Change",
                              @"Time":[self currentDate],
                              @"OldValue":[NSString stringWithFormat:@"(l:%0.1lf t:%0.1lf w:%0.1lf h:%0.1lf)",oldFrame.origin.x,oldFrame.origin.y,oldFrame.size.width,oldFrame.size.height],
                              @"NewValue":[NSString stringWithFormat:@"(l:%0.1lf t:%0.1lf w:%0.1lf h:%0.1lf)",newFrame.origin.x,newFrame.origin.y,newFrame.size.width,newFrame.size.height],
                              @"Superview":NSStringFromClass([((UIView*)object).superview class])
                              }];
    }
    else if([keyPath isEqualToString:@"tag"])
    {
        NSInteger oldVal=[change[NSKeyValueChangeOldKey] integerValue];
        NSInteger newVal=[change[NSKeyValueChangeNewKey] integerValue];
        [arrTrace addObject:@{
                              @"Key":@"Tag Change",
                              @"Time":[self currentDate],
                              @"OldValue":@(oldVal),
                              @"NewValue":@(newVal)
                              }];
    }
    else if([keyPath isEqualToString:@"userInteractionEnabled"])
    {
        BOOL oldVal=[change[NSKeyValueChangeOldKey] boolValue];
        BOOL newVal=[change[NSKeyValueChangeNewKey] boolValue];
        [arrTrace addObject:@{
                              @"Key":@"userInteractionEnabled Change",
                              @"Time":[self currentDate],
                              @"OldValue":oldVal?@"YES":@"NO",
                              @"NewValue":newVal?@"YES":@"NO"
                              }];
    }
    else if([keyPath isEqualToString:@"hidden"])
    {
        BOOL oldVal=[change[NSKeyValueChangeOldKey] boolValue];
        BOOL newVal=[change[NSKeyValueChangeNewKey] boolValue];
        [arrTrace addObject:@{
                              @"Key":@"hidden Change",
                              @"Time":[self currentDate],
                              @"OldValue":oldVal?@"YES":@"NO",
                              @"NewValue":newVal?@"YES":@"NO"
                              }];
    }
    else if([keyPath isEqualToString:@"bounds"])
    {
        CGRect oldFrame=[change[NSKeyValueChangeOldKey] CGRectValue];
        CGRect newFrame=[change[NSKeyValueChangeNewKey] CGRectValue];
        if(CGRectEqualToRect(oldFrame, newFrame))
        {
            return;
        }
        [arrTrace addObject:@{
                              @"Key":@"Bounds Change",
                              @"Time":[self currentDate],
                              @"OldValue":[NSString stringWithFormat:@"(l:%0.1lf t:%0.1lf w:%0.1lf h:%0.1lf)",oldFrame.origin.x,oldFrame.origin.y,oldFrame.size.width,oldFrame.size.height],
                              @"NewValue":[NSString stringWithFormat:@"(l:%0.1lf t:%0.1lf w:%0.1lf h:%0.1lf)",newFrame.origin.x,newFrame.origin.y,newFrame.size.width,newFrame.size.height]
                              }];
    }
    else if([keyPath isEqualToString:@"contentSize"])
    {
        CGSize oldSize=[change[NSKeyValueChangeOldKey] CGSizeValue];
        CGSize newSize=[change[NSKeyValueChangeNewKey] CGSizeValue];
        if(CGSizeEqualToSize(oldSize, newSize))
        {
            return;
        }
        [arrTrace addObject:@{
                              @"Key":@"ContentSize Change",
                              @"Time":[self currentDate],
                              @"OldValue":[NSString stringWithFormat:@"(w:%0.1lf h:%0.1lf)",oldSize.width,oldSize.height],
                              @"NewValue":[NSString stringWithFormat:@"(w:%0.1lf h:%0.1lf)",newSize.width,newSize.height]
                              }];
    }
    else if([keyPath isEqualToString:@"contentOffset"])
    {
        CGPoint oldOffset=[change[NSKeyValueChangeOldKey] CGPointValue];
        CGPoint newOffset=[change[NSKeyValueChangeNewKey] CGPointValue];
        if(CGPointEqualToPoint(oldOffset, newOffset))
        {
            return;
        }
        [arrTrace addObject:@{
                              @"Key":@"ContentOffset Change",
                              @"Time":[self currentDate],
                              @"OldValue":[NSString stringWithFormat:@"(l:%0.1lf t:%0.1lf)",oldOffset.x,oldOffset.y],
                              @"NewValue":[NSString stringWithFormat:@"(l:%0.1lf t:%0.1lf)",newOffset.x,newOffset.y]
                              }];
    }
    else if([keyPath isEqualToString:@"contentInset"])
    {
        UIEdgeInsets oldEdge=[change[NSKeyValueChangeOldKey] UIEdgeInsetsValue];
        UIEdgeInsets newEdge=[change[NSKeyValueChangeNewKey] UIEdgeInsetsValue];
        if(UIEdgeInsetsEqualToEdgeInsets(oldEdge, newEdge))
        {
            return;
        }
        [arrTrace addObject:@{
                              @"Key":@"ContentInset Change",
                              @"Time":[self currentDate],
                              @"OldValue":[NSString stringWithFormat:@"(l:%0.1lf t:%0.1lf r:%0.1lf b:%0.1lf)",oldEdge.left,oldEdge.top,oldEdge.right,oldEdge.bottom],
                              @"NewValue":[NSString stringWithFormat:@"(l:%0.1lf t:%0.1lf r:%0.1lf b:%0.1lf)",newEdge.left,oldEdge.top,newEdge.right,oldEdge.bottom]
                              }];
    }
    [_tableRight reloadData];
    _tableRight.tableFooterView=[[UIView alloc] init];
}

- (NSString *)currentDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss:SSS"];
    NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
    return destDateString;
}

-(void)analysisAutoLayout
{
    if(_viewHit.translatesAutoresizingMaskIntoConstraints==YES)
    {
        
        return;
    }
    UIView *viewContraint=_viewHit;
    while(viewContraint!=nil && ![viewContraint isKindOfClass:NSClassFromString(@"UIViewControllerWrapperView")])
    {
        for(NSLayoutConstraint *con in viewContraint.constraints)
        {
            CGFloat constant=con.constant;
            UIView *viewFirst=con.firstItem;
            UIView *viewSecond=con.secondItem;
            if(con.secondItem!=nil )
            {
                if(con.firstItem==_viewHit && con.firstAttribute==con.secondAttribute)
                {
                    if([viewFirst isDescendantOfView:viewSecond])
                    {
                        constant=con.constant;
                    }
                    else if([viewSecond isDescendantOfView:viewFirst])
                    {
                        constant=-con.constant;
                    }
                    else
                    {
                        constant=con.constant;
                    }
                }
                else if(con.firstItem==_viewHit && con.firstAttribute!=con.secondAttribute)
                {
                    constant=con.constant;
                }
                else if(con.secondItem==_viewHit && con.firstAttribute==con.secondAttribute)
                {
                    if([viewFirst isDescendantOfView:viewSecond])
                    {
                        constant=-con.constant;
                    }
                    else if([viewSecond isDescendantOfView:viewFirst])
                    {
                        constant=con.constant;
                    }
                    else
                    {
                        constant=con.constant;
                    }
                }
                else if(con.secondItem==_viewHit && con.firstAttribute!=con.secondAttribute)
                {
                    constant=con.constant;
                }
            }
            
            if(con.firstItem==_viewHit && (con.firstAttribute==NSLayoutAttributeLeading || con.firstAttribute==NSLayoutAttributeLeft || con.firstAttribute==NSLayoutAttributeLeadingMargin || con.firstAttribute==NSLayoutAttributeLeftMargin))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"Left",
                                           @"Value":con.description,
                                           @"ToView":[IDUDebugObject objectWithWeak:con.secondItem],
                                           @"Constant":@(con.constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if(con.secondItem==_viewHit && (con.secondAttribute==NSLayoutAttributeLeading || con.secondAttribute==NSLayoutAttributeLeft || con.secondAttribute==NSLayoutAttributeLeadingMargin || con.secondAttribute==NSLayoutAttributeLeftMargin))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"Left",
                                           @"Value":con.description,
                                           @"ToView":[IDUDebugObject objectWithWeak:con.firstItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if(con.firstItem==_viewHit && (con.firstAttribute==NSLayoutAttributeTop || con.firstAttribute==NSLayoutAttributeTopMargin))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"Top",
                                           @"Value":con.description,
                                           @"ToView":[IDUDebugObject objectWithWeak:con.secondItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if(con.secondItem==_viewHit && (con.secondAttribute==NSLayoutAttributeTop || con.secondAttribute==NSLayoutAttributeTopMargin))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"Top",
                                           @"Value":con.description,
                                           @"ToView":[IDUDebugObject objectWithWeak:con.firstItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if(con.firstItem==_viewHit && (con.firstAttribute==NSLayoutAttributeTrailing || con.firstAttribute==NSLayoutAttributeTrailingMargin || con.firstAttribute==NSLayoutAttributeRight || con.firstAttribute==NSLayoutAttributeRightMargin))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"Right",
                                           @"Value":con.description,
                                           @"ToView":[IDUDebugObject objectWithWeak:con.secondItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if(con.secondItem==_viewHit && (con.secondAttribute==NSLayoutAttributeTrailing || con.secondAttribute==NSLayoutAttributeTrailingMargin || con.secondAttribute==NSLayoutAttributeRight || con.secondAttribute==NSLayoutAttributeRightMargin))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"Right",
                                           @"Value":con.description,
                                           @"ToView":[IDUDebugObject objectWithWeak:con.firstItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if(con.firstItem==_viewHit && (con.firstAttribute==NSLayoutAttributeBottom || con.firstAttribute==NSLayoutAttributeBottomMargin))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"Bottom",
                                           @"Value":con.description,
                                           @"ToView":[IDUDebugObject objectWithWeak:con.secondItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if(con.secondItem==_viewHit && (con.secondAttribute==NSLayoutAttributeBottom || con.secondAttribute==NSLayoutAttributeBottomMargin))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"Bottom",
                                           @"Value":con.description,
                                           @"ToView":[IDUDebugObject objectWithWeak:con.firstItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if((con.firstItem==_viewHit && con.firstAttribute==NSLayoutAttributeWidth) || (con.secondItem==_viewHit && con.secondAttribute==NSLayoutAttributeWidth))
            {
                if([con isKindOfClass:NSClassFromString(@"NSContentSizeLayoutConstraint")])
                {
                    [arrConstrains addObject:@{
                                               @"Type":@"IntrinsicContent Width",
                                               @"Value":con.description,
                                               @"Constant":@(constant)
                                               }];
                }
                else
                {
                    [arrConstrains addObject:@{
                                               @"Type":@"Width",
                                               @"Value":con.description,
                                               @"ToView":[IDUDebugObject objectWithWeak:con.firstItem==_viewHit?con.secondItem:con.firstItem],
                                               @"Constant":@(constant),
                                               @"Multiplier":@(con.multiplier),
                                               @"Priority":@(con.priority)
                                               }];
                }
            }
            else if((con.firstItem==_viewHit && con.firstAttribute==NSLayoutAttributeHeight) || (con.secondItem==_viewHit && con.secondAttribute==NSLayoutAttributeHeight))
            {
                if([con isKindOfClass:NSClassFromString(@"NSContentSizeLayoutConstraint")])
                {
                    [arrConstrains addObject:@{
                                               @"Type":@"IntrinsicContent Height",
                                               @"Value":con.description,
                                               @"Constant":@(constant)
                                               }];
                }
                else
                {
                    [arrConstrains addObject:@{
                                               @"Type":@"Height",
                                               @"Value":con.description,
                                               @"ToView":[IDUDebugObject objectWithWeak:con.firstItem==_viewHit?con.secondItem:con.firstItem],
                                               @"Constant":@(constant),
                                               @"Multiplier":@(con.multiplier),
                                               @"Priority":@(con.priority)
                                               }];
                }
            }
            else if(con.firstItem==_viewHit && (con.firstAttribute==NSLayoutAttributeCenterX))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"CenterX",
                                           @"Value":con.description,
                                           @"ToView":[IDUDebugObject objectWithWeak:con.secondItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if(con.secondItem==_viewHit && (con.secondAttribute==NSLayoutAttributeCenterX))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"CenterX",
                                           @"Value":con.description,
                                           @"ToView":[IDUDebugObject objectWithWeak:con.firstItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if(con.firstItem==_viewHit && (con.firstAttribute==NSLayoutAttributeCenterY))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"CenterY",
                                           @"Value":con.description,
                                           @"ToView":[IDUDebugObject objectWithWeak:con.secondItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if(con.secondItem==_viewHit && (con.secondAttribute==NSLayoutAttributeCenterY))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"CenterY",
                                           @"Value":con.description,
                                           @"ToView":[IDUDebugObject objectWithWeak:con.firstItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if(con.firstItem==_viewHit && (con.firstAttribute==NSLayoutAttributeBaseline))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"BaseLine",
                                           @"Value":con.description,
                                           @"ToView":[IDUDebugObject objectWithWeak:con.secondItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
            else if(con.secondItem==_viewHit && (con.secondAttribute==NSLayoutAttributeBaseline))
            {
                [arrConstrains addObject:@{
                                           @"Type":@"BaseLine",
                                           @"Value":con.description,
                                           @"ToView":[IDUDebugObject objectWithWeak:con.firstItem],
                                           @"Constant":@(constant),
                                           @"Multiplier":@(con.multiplier),
                                           @"Priority":@(con.priority)
                                           }];
            }
        }
        viewContraint=viewContraint.superview;
    }
}

- (IBAction)onDonate:(id)sender
{
    NSMutableString *s = [[NSMutableString alloc] initWithString:@"contact me"];
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:s message:@"qq:375662923" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)initView:(UIView*)view Back:(BOOL)bBack
{
    _viewHit=view;
    _lbCurView.text=[NSString stringWithFormat:@"%@(%p)",NSStringFromClass([_viewHit class]),(void*)_viewHit];
    if(!bBack)
    {
        [arrStackView addObject:[IDUDebugObject objectWithWeak:view]];
        if(arrStackView.count>=2)
        {
            _btnBack.hidden=NO;
        }
    }
    arrSuper=[[NSMutableArray alloc] initWithCapacity:30];
    UIView *viewSuper=_viewHit;
    while ((viewSuper=viewSuper.superview)) {
        [arrSuper addObject:[IDUDebugObject objectWithWeak:viewSuper] ];
    }
    arrSub=[[NSMutableArray alloc] initWithCapacity:30];
    for(UIView *subview in _viewHit.subviews)
    {
        [arrSub addObject:[IDUDebugObject objectWithWeak:subview]];
    }
    arrTrace=[[NSMutableArray alloc] initWithCapacity:30];
  [arrTrace addObject:@{
                        @"Key":@"Frame Change"}];
    arrConstrains=[[NSMutableArray alloc] initWithCapacity:30];
  [arrConstrains addObject:@{
                        @"Key":@"Frame Change"}];
    arrGeneral=[[NSMutableArray alloc] initWithCapacity:30];
    [arrGeneral addObject:[NSString stringWithFormat:@"Class Name:%@",NSStringFromClass([_viewHit class])]];
    [arrGeneral addObject:[NSString stringWithFormat:@"AutoLayout:%@",_viewHit.translatesAutoresizingMaskIntoConstraints?@"NO":@"Yes"]];
    [arrGeneral addObject:[NSString stringWithFormat:@"Left:%0.2lf",_viewHit.frame.origin.x]];
    [arrGeneral addObject:[NSString stringWithFormat:@"Top:%0.2lf",_viewHit.frame.origin.y]];
    [arrGeneral addObject:[NSString stringWithFormat:@"Width:%0.2lf",_viewHit.frame.size.width]];
    [arrGeneral addObject:[NSString stringWithFormat:@"Height:%0.2lf",_viewHit.frame.size.height]];
    [self analysisAutoLayout];
    [_tableRight reloadData];
    _tableRight.tableFooterView=[[UIView alloc] init];
}

- (IBAction)onBack:(id)sender
{
    [arrStackView removeLastObject];
    UIView *view=((IDUDebugObject*)[arrStackView lastObject]).object;
    if(arrStackView.count==1)
    {
        _btnBack.hidden=YES;
    }
    [self initView:view Back:YES];
}

- (IBAction)onHit:(id)sender
{
    if(_viewHit==nil)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"IDUDebug" message:@"View has removed and can't hit!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:msgIDUDebugView object:_viewHit];
    [self minimize];
}

- (IBAction)onMinimize:(id)sender
{
    [self minimize];
}


-(UITableViewCell*)handleGeneralCell:(NSIndexPath*)indexPath
{
    NSString *cellID=@"IDUDebugHelpGeneralCell";
    UITableViewCell* cell=[_tableRight dequeueReusableCellWithIdentifier:cellID];
    if(cell==nil)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.numberOfLines=0;
    cell.textLabel.lineBreakMode=NSLineBreakByCharWrapping;
    cell.textLabel.frame=CGRectMake(0, 0, cell.textLabel.frame.size.width, 40);
    cell.textLabel.text=arrGeneral[indexPath.row];
    [cell.textLabel sizeToFit];
    return cell;
}

-(UITableViewCell*)handleSuperViewsCell:(NSIndexPath*)indexPath
{
    NSString *cellID=@"IDUDebugHelpSuperCell";
    UITableViewCell* cell=[_tableRight dequeueReusableCellWithIdentifier:cellID];
    if(cell==nil)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    UIView* view=((IDUDebugObject*)arrSuper[indexPath.row]).object;
    if(view==nil)
    {
        cell.textLabel.text=@"view has released";
        cell.detailTextLabel.text=@"";
    }
    else
    {
        cell.textLabel.numberOfLines=0;
        cell.textLabel.lineBreakMode=NSLineBreakByCharWrapping;
        cell.textLabel.frame=CGRectMake(0, 0, cell.textLabel.frame.size.width, 40);
        cell.textLabel.text=NSStringFromClass([view class]);
        [cell.textLabel sizeToFit];
        cell.detailTextLabel.numberOfLines=0;
        cell.detailTextLabel.lineBreakMode=NSLineBreakByCharWrapping;
        cell.detailTextLabel.frame=CGRectMake(0, 0, cell.detailTextLabel.frame.size.width, 40);
        cell.detailTextLabel.text=[NSString stringWithFormat:@"l:%0.1lf t:%0.1lf w:%0.1lf h:%0.1lf",view.frame.origin.x,view.frame.origin.y,view.frame.size.width,view.frame.size.height];
        if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]])
        {
            cell.detailTextLabel.text=[cell.detailTextLabel.text stringByAppendingString:[NSString stringWithFormat:@" text(%ld):%@",[[view valueForKey:@"text"] length],[view valueForKey:@"text"]]];
        }
        else if([view isKindOfClass:[UIButton class]])
        {
            UIButton *btn=(UIButton*)view;
            NSString *str=[btn titleForState:UIControlStateNormal];
            cell.detailTextLabel.text=[cell.detailTextLabel.text stringByAppendingString:[NSString stringWithFormat:@" text(%ld):%@",str.length,str!=nil?str:@"" ]];
        }
        [cell.detailTextLabel sizeToFit];
    }
    
    return cell;
}

-(UITableViewCell*)handleSubViewsCell:(NSIndexPath*)indexPath
{
    NSString *cellID=@"IDUDebugHelpSubCell";
    UITableViewCell* cell=[_tableRight dequeueReusableCellWithIdentifier:cellID];
    if(cell==nil)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    UIView* view=((IDUDebugObject*)arrSub[indexPath.row]).object;
    if(view==nil)
    {
        cell.textLabel.text=@"view has released";
        cell.detailTextLabel.text=@"";
    }
    else
    {
        cell.textLabel.numberOfLines=0;
        cell.textLabel.lineBreakMode=NSLineBreakByCharWrapping;
        cell.textLabel.frame=CGRectMake(0, 0, cell.textLabel.frame.size.width, 40);
        cell.textLabel.text=NSStringFromClass([view class]);
        [cell.textLabel sizeToFit];
        cell.detailTextLabel.numberOfLines=0;
        cell.detailTextLabel.lineBreakMode=NSLineBreakByCharWrapping;
        cell.detailTextLabel.frame=CGRectMake(0, 0, cell.detailTextLabel.frame.size.width, 40);
        cell.detailTextLabel.text=[NSString stringWithFormat:@"l:%0.1lf t:%0.1lf w:%0.1lf h:%0.1lf",view.frame.origin.x,view.frame.origin.y,view.frame.size.width,view.frame.size.height];
        if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]])
        {
            cell.detailTextLabel.text=[cell.detailTextLabel.text stringByAppendingString:[NSString stringWithFormat:@" text(%ld):%@",[[view valueForKey:@"text"] length],[view valueForKey:@"text"]]];
        }
        else if([view isKindOfClass:[UIButton class]])
        {
            UIButton *btn=(UIButton*)view;
            NSString *str=[btn titleForState:UIControlStateNormal];
            cell.detailTextLabel.text=[cell.detailTextLabel.text stringByAppendingString:[NSString stringWithFormat:@" text(%ld):%@",str.length,str!=nil?str:@"" ]];
        }
        [cell.detailTextLabel sizeToFit];
    }
    return cell;
}

-(UITableViewCell*)handleConstrainsCell:(NSIndexPath*)indexPath
{
    NSString *cellID=@"IDUDebugHelpConstrainsCell";
    UITableViewCell* cell=[_tableRight dequeueReusableCellWithIdentifier:cellID];
    if(cell==nil)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    NSDictionary *dic=arrConstrains[indexPath.row];
    cell.textLabel.numberOfLines=0;
    cell.textLabel.lineBreakMode=NSLineBreakByCharWrapping;
    cell.textLabel.frame=CGRectMake(0, 0, cell.textLabel.frame.size.width, 40);
    cell.textLabel.text=[NSString stringWithFormat:@"%@(Priority:%ld)" ,dic[@"Type"],(long)[dic[@"Priority"] integerValue]];
    [cell.textLabel sizeToFit];
    cell.detailTextLabel.numberOfLines=0;
    cell.detailTextLabel.lineBreakMode=NSLineBreakByCharWrapping;
    cell.detailTextLabel.frame=CGRectMake(0, 40, cell.detailTextLabel.frame.size.width, 30);
    NSArray *arrTemp=[dic[@"Value"] componentsSeparatedByString:@" "];
    NSMutableArray *arr=[[NSMutableArray alloc] initWithCapacity:30];
    for(int i=1;i<arrTemp.count;i++)
    {
        [arr addObject:arrTemp[i]];
    }
    cell.detailTextLabel.text=[[arr componentsJoinedByString:@" "] stringByReplacingOccurrencesOfString:@">" withString:@""];
    [cell.detailTextLabel sizeToFit];
    return cell;
}

-(UITableViewCell*)handleTraceCell:(NSIndexPath*)indexPath
{
    NSString *cellID=@"IDUDebugHelpTraceCell";
  
  UITableViewCell* cell=[_tableRight dequeueReusableCellWithIdentifier:cellID];
  if(cell==nil)
  {
    cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
  }
  cell.textLabel.numberOfLines=0;
  cell.textLabel.lineBreakMode=NSLineBreakByCharWrapping;
  cell.textLabel.frame=CGRectMake(0, 0, cell.textLabel.frame.size.width, 40);
  cell.textLabel.text=arrGeneral[indexPath.row];
  [cell.textLabel sizeToFit];
  return cell;
    return cell;
}

-(UITableViewCell*)handleAboutCell:(NSIndexPath*)indexPath
{
    NSString *cellID=@"IDUDebugHelpAboutCell";
    UITableViewCell* cell=[_tableRight dequeueReusableCellWithIdentifier:cellID];
    if(cell==nil)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.numberOfLines=0;
    cell.textLabel.lineBreakMode=NSLineBreakByCharWrapping;
    cell.textLabel.frame=CGRectMake(0, 0, cell.textLabel.frame.size.width, 40);
    cell.textLabel.text=arrAbout[indexPath.row];
    [cell.textLabel sizeToFit];
    return cell;
}

-(CGFloat)heightForGeneralCell:(NSIndexPath*)indexPath Width:(CGFloat)width
{
    if(indexPath.row==0)
    {
        NSString *str=arrGeneral[0];
        CGRect rect=[str boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];
        return rect.size.height+5;
    }
    else
    {
        return 44;
    }
}

-(CGFloat)heightForSuperCell:(NSIndexPath*)indexPath Width:(CGFloat)width
{
    UIView* view=((IDUDebugObject*)arrSuper[indexPath.row]).object;
    NSString *str,*strDetail;
    if(view==nil)
    {
        str=@"view has released";
        strDetail=@"";
    }
    else
    {
        str=NSStringFromClass([view class]);
        strDetail=[NSString stringWithFormat:@"l:%0.1lf t:%0.1lf w:%0.1lf h:%0.1lf",view.frame.origin.x,view.frame.origin.y,view.frame.size.width,view.frame.size.height];
        if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]])
        {
            strDetail=[strDetail stringByAppendingString:[NSString stringWithFormat:@" text(%ld):%@",[[view valueForKey:@"text"] length],[view valueForKey:@"text"]]];
        }
        else if([view isKindOfClass:[UIButton class]])
        {
            UIButton *btn=(UIButton*)view;
            NSString *str=[btn titleForState:UIControlStateNormal];
            strDetail=[strDetail stringByAppendingString:[NSString stringWithFormat:@" text(%ld):%@",str.length,str!=nil?str:@"" ]];
        }
    }
    CGRect rect=[str boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];
    CGRect rectDetail=[strDetail boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
    return rect.size.height+rectDetail.size.height+10;
}

-(CGFloat)heightForSubCell:(NSIndexPath*)indexPath Width:(CGFloat)width
{
    UIView* view=((IDUDebugObject*)arrSub[indexPath.row]).object;
    NSString *str,*strDetail;
    if(view==nil)
    {
        str=@"view has released";
        strDetail=@"";
    }
    else
    {
        str=NSStringFromClass([view class]);
        strDetail=[NSString stringWithFormat:@"l:%0.1lf t:%0.1lf w:%0.1lf h:%0.1lf",view.frame.origin.x,view.frame.origin.y,view.frame.size.width,view.frame.size.height];
        if([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]])
        {
            strDetail=[strDetail stringByAppendingString:[NSString stringWithFormat:@" text(%ld):%@",[[view valueForKey:@"text"] length],[view valueForKey:@"text"]]];
        }
        else if([view isKindOfClass:[UIButton class]])
        {
            UIButton *btn=(UIButton*)view;
            NSString *str=[btn titleForState:UIControlStateNormal];
            strDetail=[strDetail stringByAppendingString:[NSString stringWithFormat:@" text(%ld):%@",str.length,str!=nil?str:@"" ]];
        }
    }
    CGRect rect=[str boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];
    CGRect rectDetail=[strDetail boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
    return rect.size.height+rectDetail.size.height+10;
}

-(CGFloat)heightForConstrainsCell:(NSIndexPath*)indexPath Width:(CGFloat)width
{
    NSString *str,*strDetail;
    NSDictionary *dic=arrConstrains[indexPath.row];
    str=[NSString stringWithFormat:@"%@(Priority:%ld)" ,dic[@"Type"],(long)[dic[@"Priority"] integerValue]];
    NSArray *arrTemp=[dic[@"Value"] componentsSeparatedByString:@" "];
    NSMutableArray *arr=[[NSMutableArray alloc] initWithCapacity:30];
    for(int i=1;i<arrTemp.count;i++)
    {
        [arr addObject:arrTemp[i]];
    }
    strDetail=[[arr componentsJoinedByString:@" "] stringByReplacingOccurrencesOfString:@">" withString:@""];
    CGRect rect=[str boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];
    CGRect rectDetail=[strDetail boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
    return rect.size.height+rectDetail.size.height+10;
}

-(CGFloat)heightForTraceCell:(NSIndexPath*)indexPath Width:(CGFloat)width
{
    NSString *str,*strDetail;
    NSDictionary *dic=arrTrace[indexPath.row];
    str=[NSString stringWithFormat:@"%@(%@)",dic[@"Key"],dic[@"Time"]];
    strDetail=[NSString stringWithFormat:@"from %@ to %@",dic[@"OldValue"],dic[@"NewValue"]];
    if([dic[@"Key"] isEqualToString:@"superview.frame"])
    {
        strDetail=[[NSString stringWithFormat:@"%@ ",dic[@"Superview"]] stringByAppendingString:strDetail];
    }
    CGRect rect=[str boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];
    CGRect rectDetail=[strDetail boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
    return rect.size.height+rectDetail.size.height+10;
}

-(CGFloat)heightForAboutCell:(NSIndexPath*)indexPath Width:(CGFloat)width
{
    if(indexPath.row==0)
    {
        if(version!=0)
        {
            if(version>VERSION)
            {
                arrAbout[0]=[NSString stringWithFormat:@"375662923idu%f",version];
            }
            else
            {
                arrAbout[0]=@"帅气的我";
            }
        }
    }
    NSString *str=arrAbout[indexPath.row];
    CGRect rect=[str boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];
    return rect.size.height+5;
}

-(void)onTrace:(UIButton*)btn
{


  
}
- (UIViewController *)findViewController:(UIView *)sourceView
{
  id target=sourceView;
  while (target) {
    target = ((UIResponder *)target).nextResponder;
    if ([target isKindOfClass:[UIViewController class]]) {
      break;
    }
  }
  return target;
  
}

-(void)minimize
{
    originFrame=self.frame;
    CGRect frame=CGRectMake([UIScreen mainScreen].bounds.size.width-20, [UIScreen mainScreen].bounds.size.height/2-20, 20, 40);
    [UIView animateWithDuration:0.2 animations:^{
        self.frame=frame;
    } completion:^(BOOL finished) {
        UIButton *btn=[[UIButton alloc] initWithFrame:self.bounds];
        [btn setTitle:@"<" forState:UIControlStateNormal];
        btn.backgroundColor=[UIColor blackColor];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(expand:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }];
}
@end










