//
//  AStarViewModel.m
//  IANLearn
//
//  Created by iMAC_HYH on 2018/5/3.
//  Copyright © 2018年 cdeledu. All rights reserved.
//

#import "AStarViewModel.h"

@implementation AStarViewModel

- (instancetype)initWithArray:(NSArray *)array {
    if (self = [super init]) {
        NSMutableArray *arr = [NSMutableArray array];
        for (NSUInteger row = 0; row < array.count; row++) {
            NSArray *rowArray = array[row];
            NSMutableArray *rowViewModels = [NSMutableArray array];
            for (NSUInteger col = 0; col < rowArray.count; col++) {
                ANodeViewModel *vm = [ANodeViewModel new];
                vm.row = row;
                vm.col = col;
                if ([rowArray[col] integerValue] == 1) {
                    vm.nodeType = ANodeTypeObstancle;
                } else {
                    vm.nodeType = ANodeTypeEmpty;
                }
                [rowViewModels addObject:vm];
             }
            [arr addObject:rowViewModels];
        }
        _nodeViewModels = [arr copy];
    }
    return self;
}

- (NSArray *)mapArray {
    NSMutableArray *mapArray = [NSMutableArray array];
    for (int row = 0; row < self.nodeViewModels.count; row++) {
        NSArray<ANodeViewModel *> *rowViewModels = self.nodeViewModels[row];
        NSMutableArray *rowArray = [NSMutableArray array];
        for (int col = 0; col < rowViewModels.count; col++) {
            [rowArray addObject:@(rowViewModels[col].nodeType == ANodeTypeObstancle)];
        }
        [mapArray addObject:rowArray];
    }
    return mapArray;
}

@end

@implementation ANodeViewModel

- (void)setNodeType:(ANodeType)nodeType {
    _nodeType = nodeType;
    if (self.typeChanged) {
        self.typeChanged(nodeType);
    }
}

- (void)setArrowDirection:(NodeDirection)arrowDirection {
    _arrowDirection = arrowDirection;
    if (self.directionChanged) {
        self.directionChanged(arrowDirection);
    }
}

@end
