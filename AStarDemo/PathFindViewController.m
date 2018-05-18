//
//  PathFindViewController.m
//  IANLearn
//
//  Created by iMAC_HYH on 2018/3/23.
//  Copyright © 2018年 ian.Devs. All rights reserved.
//

#import "PathFindViewController.h"
#import "PathFindNodeButton.h"
#import "PathFindViewModel.h"
#import "PathFindMap.h"
#import "AStar.h"
#import "BFS.h"
#import "DFS.h"
#import <Masonry/Masonry.h>

typedef NS_ENUM(NSInteger, PathFindType) {
    PathFindTypeBFS,
    PathFindTypeDFS,
    PathFindTypeAStar
};

static const NSUInteger kMAP_SIZE = 12;

@interface PathFindViewController ()

@property (nonatomic, strong) PathFindViewModel *viewModel;
@property (nonatomic, strong) UISegmentedControl *findTypeSegment;

@end

@implementation PathFindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewModel = [[PathFindViewModel alloc] initWithSize:kMAP_SIZE];
    self.viewModel.operateType = AOperateTypeSetStart;
    
    [self initUI];
}

- (void)initUI {
    // title
    self.title = @"Path-finding";
    
    // top segment
    UISegmentedControl *findTypeSegment = [[UISegmentedControl alloc] initWithItems:@[@"BFS", @"DFS", @"A~*"]];
    findTypeSegment.tintColor = [UIColor blueColor];
    [findTypeSegment addTarget:self action:@selector(findTypeChanged:) forControlEvents:UIControlEventValueChanged];
    findTypeSegment.selectedSegmentIndex = 0;
    for (NSUInteger i = 0; i < findTypeSegment.numberOfSegments; i++) {
        [findTypeSegment setWidth:50 forSegmentAtIndex:i];
    }
    // map view
    double width = ([UIScreen mainScreen].bounds.size.width - 10) / kMAP_SIZE;
    UIView *panel = [UIView new];
    for (int row = 0; row < self.viewModel.nodeViewModels.count; row++) {
        NSArray<PathFindNodeViewModel *> *rowViewModels = self.viewModel.nodeViewModels[row];
        for (int col = 0; col < rowViewModels.count; col++) {
            PathFindNodeViewModel *nodeViewModel = rowViewModels[col];
            PathFindNodeButton *button = [PathFindNodeButton new];
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
    // bottom segment
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"start", @"end", @"rock"]];
    segmentedControl.tintColor = [UIColor blueColor];
    [segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex = 0;
    for (NSUInteger i = 0; i < segmentedControl.numberOfSegments; i++) {
        [segmentedControl setWidth:50 forSegmentAtIndex:i];
    }
    // button clear
    UIButton *btn1 = [UIButton new];
    btn1.backgroundColor = [UIColor grayColor];
    [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn1 setTitle:@"clear" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(btn1Click) forControlEvents:UIControlEventTouchUpInside];
    // button find
    UIButton *btn2 = [UIButton new];
    btn2.backgroundColor = [UIColor grayColor];
    [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn2 setTitle:@"find" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(btn2Click) forControlEvents:UIControlEventTouchUpInside];
    
    // add to superview
    [self.view addSubview:findTypeSegment];
    [self.view addSubview:panel];
    [self.view addSubview:segmentedControl];
    [self.view addSubview:btn1];
    [self.view addSubview:btn2];
    
    // layout
    [findTypeSegment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(panel.mas_top).offset(-5);
        make.width.mas_equalTo(50 * 3);
        make.height.equalTo(@30);
    }];
    [panel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
        make.left.equalTo(self.view.mas_left).offset(5);
        make.right.equalTo(self.view.mas_right).offset(-5);
        make.height.width.mas_equalTo(width * kMAP_SIZE);
    }];
    [segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).mas_offset(5);
        make.top.equalTo(panel.mas_bottom).offset(5);
        make.width.mas_equalTo(50 * 3);
        make.height.equalTo(@30);
    }];
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
    
    self.findTypeSegment = findTypeSegment;
}

- (void)btn1Click {
    [self clearMap];
}

- (void)btn2Click {
    [self findPathWithType:self.findTypeSegment.selectedSegmentIndex];
}

- (void)clearMap {
    for (int row = 0; row < self.viewModel.nodeViewModels.count; row++) {
        NSArray<PathFindNodeViewModel *> *rowViewModels = self.viewModel.nodeViewModels[row];
        for (int col = 0; col < rowViewModels.count; col++) {
            PathFindNodeViewModel *nodeViewModel = rowViewModels[col];
            nodeViewModel.nodeType = ANodeTypeEmpty;
            nodeViewModel.arrowDirection = NodeDirectionNone;
        }
    }
}

- (void)findPathWithType:(PathFindType)findType {
    for (int row = 0; row < self.viewModel.nodeViewModels.count; row++) {
        NSArray<PathFindNodeViewModel *> *rowViewModels = self.viewModel.nodeViewModels[row];
        for (int col = 0; col < rowViewModels.count; col++) {
            PathFindNodeViewModel *nodeViewModel = rowViewModels[col];
            if (nodeViewModel.nodeType == ANodeTypePath || nodeViewModel.nodeType == ANodeTypeSearch) {
                nodeViewModel.nodeType = ANodeTypeEmpty;
            }
            nodeViewModel.arrowDirection = NodeDirectionNone;
        }
    }
    
    PathFindMap *map = [[PathFindMap alloc] initWithArray:self.viewModel.mapArray];
    NSString *startKey = [NSString stringWithFormat:@"%lu_%lu", (unsigned long)self.viewModel.start.row, (unsigned long)self.viewModel.start.col];
    NSString *endKey = [NSString stringWithFormat:@"%lu_%lu", (unsigned long)self.viewModel.end.row, (unsigned long)self.viewModel.end.col];
    PathFindNode *startNode = map.nodesDic[startKey];
    PathFindNode *endNode = map.nodesDic[endKey];
    NSMutableArray<PathFindNode *> *openedList = [NSMutableArray array];
    NSMutableArray<PathFindNode *> *closedList = [NSMutableArray array];
    
    [self findWithMap:map startNode:startNode endNode:endNode closedList:closedList openedList:openedList type:findType];
}

- (void)findWithMap:(PathFindMap *)map
          startNode:(PathFindNode *)startNode
            endNode:(PathFindNode *)endNode
         closedList:(NSMutableArray<PathFindNode *> *)closedList
         openedList:(NSMutableArray<PathFindNode *> *)openedList
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
    
    // print search area
    for (PathFindNode *node in openedList) {
        if ([node isEqual:startNode]) continue;
        NSUInteger row = node.row;
        NSUInteger col = node.col;
        PathFindNodeViewModel *nodeViewModel = self.viewModel.nodeViewModels[row][col];
        if (![node isEqual:endNode]) nodeViewModel.nodeType = ANodeTypeSearch;
        nodeViewModel.arrowDirection = node.parentDirection;
    }
    for (PathFindNode *node in closedList) {
        if ([node isEqual:startNode]) continue;
        NSUInteger row = node.row;
        NSUInteger col = node.col;
        PathFindNodeViewModel *nodeViewModel = self.viewModel.nodeViewModels[row][col];
        if (![node isEqual:endNode]) nodeViewModel.nodeType = ANodeTypeSearch;
        nodeViewModel.arrowDirection = node.parentDirection;
    }
    // print path
    if (findSuccedd) {
        PathFindNode *node = endNode;
        while (node.parent && ![node.parent isEqual:startNode]) {
            node = node.parent;
            NSUInteger row = node.row;
            NSUInteger col = node.col;
            PathFindNodeViewModel *nodeViewModel = self.viewModel.nodeViewModels[row][col];
            nodeViewModel.nodeType = ANodeTypePath;
            nodeViewModel.arrowDirection = node.parentDirection;
        }
    }
}

- (void)findTypeChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0: [self findPathWithType:PathFindTypeBFS]; break;
        case 1: [self findPathWithType:PathFindTypeDFS]; break;
        case 2: [self findPathWithType:PathFindTypeAStar]; break;
        default: break;
    }
}

- (void)nodeClick:(PathFindNodeButton *)button {
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
        if (button.viewModel.nodeType != ANodeTypeStart && button.viewModel.nodeType != ANodeTypeEnd) {
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
