//
//  IDUDebugHelp.h
//  IDUDebug
//
//  Created by idu on 2017/5/27.
//  Copyright © 2017年 idu. All rights reserved.
//

#import <UIKit/UIKit.h>
extern NSString *msgIDUDebugView;
extern NSString *msgIDUDebugRemoveView;
extern NSString *msgIDUDebugRemoveSubView;
extern NSString *msgIDUDebugAddSubView;
extern NSString *msgIDUDebugContraints;
extern NSString *msgIDUDebugShow;
extern CGFloat version;
@interface IDUDebugObject:NSObject
+(instancetype)objectWithWeak:(id)o;
@property (weak,nonatomic) id object;
@end
@interface IDUDebugHelp : UIView

@property (weak,nonatomic) UIView* viewHit;
- (IBAction)onClose:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *btnClose;
@property (strong, nonatomic) IBOutlet UILabel *lbCurView;
- (IBAction)onDonate:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *tableLeft;
@property (strong, nonatomic) IBOutlet UITableView *tableRight;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
- (IBAction)onBack:(id)sender;
- (IBAction)onHit:(id)sender;
- (IBAction)onMinimize:(id)sender;


@end
