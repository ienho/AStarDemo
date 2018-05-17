//
//  PathFindNodeButton.m
//  AStarDemo
//
//  Created by iMAC_HYH on 2018/5/17.
//  Copyright © 2018年 ian.Devs. All rights reserved.
//

#import "PathFindNodeButton.h"
#import "PathFindViewModel.h"
#import <Masonry/Masonry.h>

@implementation PathFindNodeButton {
    UIView *_contentView;
    UILabel *_arrow;
}

- (instancetype)init {
    if (self = [super init]) {
        // panel
        _contentView = [UIView new];
        _contentView.layer.borderWidth = 1;
        _contentView.layer.borderColor = [[UIColor grayColor] CGColor];
        _contentView.userInteractionEnabled = NO;
        // arrow
        _arrow = [UILabel new];
        _arrow.textColor = [UIColor blackColor];
        _arrow.backgroundColor = [UIColor clearColor];
        _arrow.textAlignment = NSTextAlignmentCenter;
        _arrow.text = @"→";
        _arrow.userInteractionEnabled = NO;
        _arrow.hidden = YES;
        
        [self addSubview:_contentView];
        [self addSubview:_arrow];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(1, 1, 1, 1));
        }];
        [_arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }
    return self;
}

- (void)setViewModel:(PathFindNodeViewModel *)viewModel {
    _viewModel = viewModel;
    
    [self setButtonType:viewModel.nodeType];
    [self setButtonArrow:viewModel.arrowDirection];
    __weak typeof(self) weakSelf = self;
    _viewModel.typeChanged = ^(ANodeType nodeType) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf setButtonType:nodeType];
        }
    };
    _viewModel.directionChanged = ^(NodeDirection direction) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf setButtonArrow:direction];
        }
    };
}

- (void)setButtonType:(ANodeType)nodeType {
    switch (nodeType) {
        case ANodeTypeEmpty:
            _contentView.backgroundColor = [UIColor clearColor];
            break;
        case ANodeTypeStart:
            _contentView.backgroundColor = [UIColor colorWithRed:0 green:80 / 255. blue:1 alpha:1];
            break;
        case ANodeTypeEnd:
            _contentView.backgroundColor = [UIColor redColor];
            break;
        case ANodeTypePath:
            _contentView.backgroundColor = [UIColor colorWithRed:0 green:196 / 255. blue:0 alpha:1];
            break;
        case ANodeTypeSearch:
            _contentView.backgroundColor = [UIColor clearColor];
            break;
        case ANodeTypeObstancle:
            _contentView.backgroundColor = [UIColor blackColor];
            break;
            
        default:
            break;
    }
}

- (void)setButtonArrow:(NodeDirection)directoin {
    _arrow.hidden = NO;
    switch (directoin) {
        case NodeDirectionNone:
            _arrow.hidden = YES;
            break;
        case NodeDirectionTop:
            _arrow.layer.transform = CATransform3DMakeRotation(-M_PI / 2, 0, 0, 1);
            break;
        case NodeDirectionLeftTop:
            _arrow.layer.transform = CATransform3DMakeRotation(-M_PI * 3 / 4, 0, 0, 1);
            break;
        case NodeDirectionLeft:
            _arrow.layer.transform = CATransform3DMakeRotation(M_PI * 4 / 4, 0, 0, 1);
            break;
        case NodeDirectionLeftBottom:
            _arrow.layer.transform = CATransform3DMakeRotation(M_PI * 3 / 4, 0, 0, 1);
            break;
        case NodeDirectionBottom:
            _arrow.layer.transform = CATransform3DMakeRotation(M_PI * 2 / 4, 0, 0, 1);
            break;
        case NodeDirectionRightBottom:
            _arrow.layer.transform = CATransform3DMakeRotation(M_PI * 1 / 4, 0, 0, 1);
            break;
        case NodeDirectionRight:
            _arrow.layer.transform = CATransform3DMakeRotation(0, 0, 0, 1);
            break;
        case NodeDirectionRightTop:
            _arrow.layer.transform = CATransform3DMakeRotation(-M_PI * 1 / 4, 0, 0, 1);
            break;
            
        default:
            break;
    }
}

@end
