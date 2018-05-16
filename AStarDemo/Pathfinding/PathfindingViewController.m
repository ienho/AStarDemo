//
//  PathfindingViewController.m
//  IANLearn
//
//  Created by iMAC_HYH on 2018/3/23.
//  Copyright © 2018年 cdeledu. All rights reserved.
//

#import "PathfindingViewController.h"
#import "AStarViewModel.h"
#import "AFindMap.h"
#import "AStar.h"
#import "BFS.h"
#import "DFS.h"
#import "Dijkstra.h"
#import <Masonry/Masonry.h>

typedef NS_ENUM(NSInteger, PathFindType) {
    PathFindTypeBFS,
    PathFindTypeDFS,
    PathFindTypeDijkstra,
    PathFindTypeAStar
};

@interface PathfindingViewController ()

@property (nonatomic, strong) AStarViewModel *viewModel;
@property (nonatomic, strong) UISegmentedControl *findTypeSegment;

@end

@implementation PathfindingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Path-finding";
    
    NSArray *array = @[@[@1, @0, @1, @0, @0, @0, @0, @0, @0, @0, @0, @0],
                       @[@1, @0, @0, @0, @1, @0, @0, @0, @0, @0, @0, @0],
                       @[@0, @0, @1, @0, @0, @0, @1, @0, @0, @1, @0, @0],
                       @[@0, @0, @0, @1, @0, @0, @0, @0, @0, @0, @0, @0],
                       @[@1, @1, @0, @1, @0, @1, @0, @1, @0, @0, @1, @0],
                       @[@1, @0, @0, @0, @0, @0, @1, @0, @0, @0, @0, @0],
                       @[@0, @0, @0, @1, @1, @0, @0, @0, @0, @1, @0, @0],
                       @[@0, @0, @0, @1, @1, @0, @0, @0, @0, @0, @0, @0],
                       @[@0, @0, @0, @1, @1, @0, @0, @0, @0, @0, @0, @0],
                       @[@0, @0, @0, @1, @1, @0, @0, @0, @0, @0, @0, @1],
                       @[@0, @0, @0, @1, @1, @0, @0, @0, @0, @0, @0, @0],
                       @[@0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0]];
    
    self.viewModel = [[AStarViewModel alloc] initWithArray:array];
    self.viewModel.operateType = AOperateTypeSetStart;
    
    double width = ([UIScreen mainScreen].bounds.size.width - 10) / array.count;
    
    UIView *panel = [UIView new];
    [self.view addSubview:panel];
    [panel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
        make.left.equalTo(self.view.mas_left).offset(5);
        make.right.equalTo(self.view.mas_right).offset(-5);
        make.height.width.mas_equalTo(width * array.count);
    }];
    
    // create map view
    for (int row = 0; row < self.viewModel.nodeViewModels.count; row++) {
        NSArray<ANodeViewModel *> *rowViewModels = self.viewModel.nodeViewModels[row];
        for (int col = 0; col < rowViewModels.count; col++) {
            ANodeViewModel *nodeViewModel = rowViewModels[col];
            ANodeButton *button = [ANodeButton new];
            [panel addSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(panel.mas_left).offset(nodeViewModel.col * width);
                make.top.equalTo(panel.mas_top).offset(nodeViewModel.row * width);
                make.width.height.mas_equalTo(width);
            }];
            button.viewModel = nodeViewModel;
            [button addTarget:self action:@selector(nodeClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    UISegmentedControl *findTypeSegment = [[UISegmentedControl alloc] initWithItems:@[@"BFS", @"DFS", @"Dijkstra", @"A~*"]];
    findTypeSegment.tintColor = [UIColor blueColor];
    for (NSUInteger i = 0; i < findTypeSegment.numberOfSegments; i++) {
        [findTypeSegment setWidth:50 forSegmentAtIndex:i];
    }
    [findTypeSegment addTarget:self action:@selector(findTypeChanged:) forControlEvents:UIControlEventValueChanged];
    findTypeSegment.selectedSegmentIndex = 0;
    [self.view addSubview:findTypeSegment];
    [findTypeSegment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(panel.mas_top).offset(-5);
        make.width.mas_equalTo(50 * 4);
        make.height.equalTo(@30);
    }];
    self.findTypeSegment = findTypeSegment;
    self.findTypeSegment.selectedSegmentIndex = 3;
//    self.findTypeSegment.hidden = YES;
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"start", @"end", @"rock"]];
    segmentedControl.tintColor = [UIColor blueColor];
    for (NSUInteger i = 0; i < segmentedControl.numberOfSegments; i++) {
        [segmentedControl setWidth:50 forSegmentAtIndex:i];
    }
    [segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex = 0;
    [self.view addSubview:segmentedControl];
    [segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).mas_offset(5);
        make.top.equalTo(panel.mas_bottom).offset(5);
        make.width.mas_equalTo(50 * 3);
        make.height.equalTo(@30);
    }];
    
    UIButton *btn1 = [UIButton new];
    btn1.backgroundColor = [UIColor grayColor];
    [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn1 setTitle:@"clear" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(btn1Click) forControlEvents:UIControlEventTouchUpInside];

    UIButton *btn2 = [UIButton new];
    btn2.backgroundColor = [UIColor grayColor];
    [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn2 setTitle:@"find" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(btn2Click) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn1];
    [self.view addSubview:btn2];
    [btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(panel.mas_bottom).offset(5);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(30);
        make.right.equalTo(btn2.mas_left).offset(-5);
    }];
    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(panel.mas_bottom).offset(5);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(30);
        make.right.equalTo(panel.mas_right);
    }];
}

- (void)btn1Click {
    [self clearMap];
}

- (void)btn2Click {
    [self findPathWithType:self.findTypeSegment.selectedSegmentIndex];
}

- (void)clearMap {
    for (int row = 0; row < self.viewModel.nodeViewModels.count; row++) {
        NSArray<ANodeViewModel *> *rowViewModels = self.viewModel.nodeViewModels[row];
        for (int col = 0; col < rowViewModels.count; col++) {
            ANodeViewModel *nodeViewModel = rowViewModels[col];
            nodeViewModel.nodeType = ANodeTypeEmpty;
            nodeViewModel.arrowDirection = NodeDirectionNone;
        }
    }
}

- (void)findPathWithType:(PathFindType)findType {
    for (int row = 0; row < self.viewModel.nodeViewModels.count; row++) {
        NSArray<ANodeViewModel *> *rowViewModels = self.viewModel.nodeViewModels[row];
        for (int col = 0; col < rowViewModels.count; col++) {
            ANodeViewModel *nodeViewModel = rowViewModels[col];
            if (nodeViewModel.nodeType == ANodeTypePath || nodeViewModel.nodeType == ANodeTypeSearch) {
                nodeViewModel.nodeType = ANodeTypeEmpty;
            }
            nodeViewModel.arrowDirection = NodeDirectionNone;
        }
    }
    
    AFindMap *map = [[AFindMap alloc] initWithArray:self.viewModel.mapArray];
    NSString *startKey = [NSString stringWithFormat:@"%lu_%lu", (unsigned long)self.viewModel.start.row, (unsigned long)self.viewModel.start.col];
    NSString *endKey = [NSString stringWithFormat:@"%lu_%lu", (unsigned long)self.viewModel.end.row, (unsigned long)self.viewModel.end.col];
    AStarNode *startNode = map.nodesDic[startKey];
    AStarNode *endNode = map.nodesDic[endKey];
        NSMutableArray<AStarNode *> *openedList = [NSMutableArray array];
        NSMutableArray<AStarNode *> *closedList = [NSMutableArray array];
    
        [self findWithMap:map startNode:startNode endNode:endNode closedList:closedList openedList:openedList type:findType];
}

- (void)findWithMap:(AFindMap *)map
          startNode:(AStarNode *)startNode
            endNode:(AStarNode *)endNode
         closedList:(NSMutableArray<AStarNode *> *)closedList
         openedList:(NSMutableArray<AStarNode *> *)openedList
               type:(PathFindType)type {
    BOOL findSuccedd = NO;
    switch (type) {
        case PathFindTypeBFS:
            findSuccedd = [BFS findPathWithMap:map
                                         start:startNode
                                           end:endNode
                                    closedList:closedList
                                    openedList:openedList];
            break;
        case PathFindTypeDFS:
            findSuccedd = [DFS findPathWithMap:map
                                         start:startNode
                                           end:endNode
                                    closedList:closedList
                                    openedList:openedList];
            break;
        case PathFindTypeDijkstra:
            findSuccedd = [Dijkstra findPathWithMap:map
                                              start:startNode
                                                end:endNode
                                         closedList:closedList
                                         openedList:openedList];
            break;
        case PathFindTypeAStar:
            findSuccedd = [AStar findPathWithMap:map
                                           start:startNode
                                             end:endNode
                                      closedList:closedList
                                      openedList:openedList];
            break;
            
        default:
            break;
    }
    for (AStarNode *node in openedList) {
        if ([node isEqual:startNode]) {
            continue;
        }
        NSUInteger row = node.row;
        NSUInteger col = node.col;
        ANodeViewModel *nodeViewModel = self.viewModel.nodeViewModels[row][col];
        if (![node isEqual:endNode]) nodeViewModel.nodeType = ANodeTypeSearch;
        nodeViewModel.arrowDirection = node.parentDirection;
    }
    for (AStarNode *node in closedList) {
        if ([node isEqual:startNode]) {
            continue;
        }
        NSUInteger row = node.row;
        NSUInteger col = node.col;
        ANodeViewModel *nodeViewModel = self.viewModel.nodeViewModels[row][col];
        if (![node isEqual:endNode]) nodeViewModel.nodeType = ANodeTypeSearch;
        nodeViewModel.arrowDirection = node.parentDirection;
    }
    if (findSuccedd) {
        AStarNode *node = endNode;
        while (node.parent && ![node.parent isEqual:startNode]) {
            node = node.parent;
            NSUInteger row = node.row;
            NSUInteger col = node.col;
            ANodeViewModel *nodeViewModel = self.viewModel.nodeViewModels[row][col];
            nodeViewModel.nodeType = ANodeTypePath;
            nodeViewModel.arrowDirection = node.parentDirection;
        }
    }
}

- (void)findTypeChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0: [self findPathWithType:PathFindTypeBFS]; break;
        case 1: [self findPathWithType:PathFindTypeDFS]; break;
        case 2: [self findPathWithType:PathFindTypeDijkstra]; break;
        case 3: [self findPathWithType:PathFindTypeAStar]; break;
        default: break;
    }
}

- (void)nodeClick:(ANodeButton *)button {
    if (self.viewModel.operateType == AOperateTypeSetStart) {
        if (self.viewModel.start != button.viewModel && button.viewModel.nodeType != ANodeTypeEnd) {
            self.viewModel.start.nodeType = ANodeTypeEmpty;
            self.viewModel.start = button.viewModel;
            self.viewModel.start.nodeType = ANodeTypeStart;
        }
    } else if (self.viewModel.operateType == AOperateTypeSetEnd) {
        if (self.viewModel.end != button.viewModel && button.viewModel.nodeType != ANodeTypeStart) {
            self.viewModel.end.nodeType = ANodeTypeEmpty;
            self.viewModel.end = button.viewModel;
            self.viewModel.end.nodeType = ANodeTypeEnd;
        }
    } else if (self.viewModel.operateType == AOperateTypeSetObstancle) {
        if (button.viewModel.nodeType != ANodeTypeStart || button.viewModel.nodeType != AOperateTypeSetEnd) {
            button.viewModel.nodeType = (button.viewModel.nodeType == ANodeTypeObstancle? ANodeTypeEmpty : ANodeTypeObstancle);
        }
    }
}

- (void)segmentedControlValueChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0: self.viewModel.operateType = AOperateTypeSetStart; break;
        case 1: self.viewModel.operateType = AOperateTypeSetEnd; break;
        case 2: self.viewModel.operateType = AOperateTypeSetObstancle; break;
        default: break;
    }
}

@end

@implementation ANodeButton {
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

- (void)setViewModel:(ANodeViewModel *)viewModel {
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
