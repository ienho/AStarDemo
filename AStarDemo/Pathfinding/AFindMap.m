//
//  AFindMap.m
//  IANLearn
//
//  Created by iMAC_HYH on 2018/5/4.
//  Copyright © 2018年 cdeledu. All rights reserved.
//

#import "AFindMap.h"

@implementation AStarNode

+ (instancetype)nodeWithRow:(NSUInteger)row col:(NSUInteger)col {
    AStarNode *node = [AStarNode new];
    node.row = row;
    node.col = col;
    return node;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[AStarNode class]]) {
        return NO;
    }
    
    if (object == self) {
        return YES;
    }
    
    AStarNode *temp = (AStarNode *)object;
    if (temp.row == self.row && temp.col == self.col) {
        return YES;
    }
    return NO;
}

- (NSUInteger)hash {
    return self.row ^ self.col;
}

- (NSString *)key {
    return [NSString stringWithFormat:@"%lu_%lu", (unsigned long)_row, (unsigned long)_col];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"node: %lu-%lu", (unsigned long)_row, (unsigned long)_col];
}

@end

@implementation AFindMap

- (instancetype)initWithArray:(NSArray *)array {
    if (self = [super init]) {
        if (array && array.count) {
//            _allSteps = @[Step(-1, 0, 10),  // top
//                          Step(-1, -1, 14), // left top
//                          Step(0, -1, 10),  // left
//                          Step(1, -1, 14),  // left bottom
//                          Step(1, 0, 10),   // bottom
//                          Step(1, 1, 14),   // right bottom
//                          Step(0, 1, 10),   // right
//                          Step(-1, 1, 14)]; // right top
            _allSteps = @[Step(-1, 0, 10),  // top
                          Step(0, -1, 10),  // left
                          Step(1, 0, 10),   // bottom
                          Step(0, 1, 10)];  // right
            _rowsCount = array.count;
            _colsCount = ((NSArray *)array.firstObject).count;
            NSMutableDictionary<NSString *, AStarNode *> *nodesDic = [NSMutableDictionary dictionary];
            for (NSUInteger row = 0; row < array.count; row++) {
                NSArray *rowArray = array[row];
                for (NSUInteger col = 0; col < rowArray.count; col++) {
                    AStarNode *node = [[AStarNode alloc] init];
                    node.row = row;
                    node.col = col;
                    node.isObstacle = [rowArray[col] integerValue] == 1;
                    [nodesDic setValue:node forKey:node.key];
                }
            }
            _nodesDic = nodesDic;
        }
    }
    return self;
}

+ (NodeDirection)parentDirectionWithStep:(MoveStep *)step {
    if ([step isEqual:Step(-1, 0, 0)]) return NodeDirectionBottom;
    if ([step isEqual:Step(-1, -1, 0)]) return NodeDirectionRightBottom;
    if ([step isEqual:Step(0, -1, 0)]) return NodeDirectionRight;
    if ([step isEqual:Step(1, -1, 0)]) return NodeDirectionRightTop;
    if ([step isEqual:Step(1, 0, 0)]) return NodeDirectionTop;
    if ([step isEqual:Step(1, 1, 0)]) return NodeDirectionLeftTop;
    if ([step isEqual:Step(0, 1, 0)]) return NodeDirectionLeft;
    if ([step isEqual:Step(-1, 1, 0)]) return NodeDirectionLeftBottom;
    return NodeDirectionNone;
}

@end

@implementation MoveStep

+ (MoveStep *)stepWithRow:(NSUInteger)row col:(NSUInteger)col cost:(NSUInteger)cost {
    MoveStep *step = [MoveStep new];
    step.row = row;
    step.col = col;
    step.cost = cost;
    return step;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    if (object == self) {
        return YES;
    }
    MoveStep *step = (MoveStep *)object;
    if (step.row == self.row && step.col == self.col) {
        return YES;
    }
    return NO;
}

@end
