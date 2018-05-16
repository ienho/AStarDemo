//
//  PathfindingViewController.h
//  IANLearn
//
//  Created by iMAC_HYH on 2018/3/23.
//  Copyright © 2018年 cdeledu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ANodeViewModel;

@interface PathfindingViewController : UIViewController

@end

@interface ANodeButton : UIControl

@property (nonatomic, strong) ANodeViewModel *viewModel;

@end
