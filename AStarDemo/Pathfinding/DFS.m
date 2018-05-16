//
//  DFS.m
//  IANLearn
//
//  Created by iMAC_HYH on 2018/5/7.
//  Copyright © 2018年 cdeledu. All rights reserved.
//

#import "DFS.h"
#import "AFindMap.h"

@implementation DFS

+ (BOOL)findPathWithMap:(AFindMap *)map
                  start:(AStarNode *)start
                    end:(AStarNode *)end
             closedList:(NSMutableArray<AStarNode *> *)closedList
             openedList:(NSMutableArray<AStarNode *> *)openedList {
    
    if (!start || !end) {
        return NO;
    }
    
    [openedList addObject:start];
    [DFS searchOpenedList:openedList closedList:closedList map:map end:end];
    if (end.parent) {
        return YES;
    }
    return NO;
}

+ (BOOL)searchOpenedList:(NSMutableArray<AStarNode *> *)openedList
             closedList:(NSMutableArray<AStarNode *> *)closedList
                     map:(AFindMap *)map
                     end:(AStarNode *)end {

    if (openedList.count == 0) {
        return YES;
    }
    AStarNode *node = openedList.firstObject;
    if ([node isEqual:end]) {
        return YES;
    }
    
    BOOL isFinished = NO;
    for (MoveStep *step in map.allSteps) {
        NSString *key = [NSString stringWithFormat:@"%lu_%lu", (unsigned long)node.row + step.row, (unsigned long)node.col + step.col];
        AStarNode *nearNode = map.nodesDic[key];
        if (nearNode && !nearNode.isObstacle && ![openedList containsObject:nearNode]) {
            nearNode.parent = node;
            nearNode.parentDirection = [AFindMap parentDirectionWithStep:step];
            [openedList insertObject:nearNode atIndex:0];
            // 递归
            if ([DFS searchOpenedList:openedList closedList:closedList map:map end:end]) {
                isFinished = YES;
                break;
            }
        }
    }
    
    [openedList removeObject:node];
    [closedList addObject:node];
    return isFinished;
}

@end
