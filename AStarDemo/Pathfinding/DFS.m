//
//  DFS.m
//  IANLearn
//
//  Created by iMAC_HYH on 2018/5/7.
//  Copyright © 2018年 ian.Devs. All rights reserved.
//

#import "DFS.h"
#import "PathFindMap.h"

@implementation DFS

+ (BOOL)findPathWithMap:(PathFindMap *)map
                  start:(PathFindNode *)start
                    end:(PathFindNode *)end
             closedList:(NSMutableArray<PathFindNode *> *)closedList
             openedList:(NSMutableArray<PathFindNode *> *)openedList {
    
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

+ (BOOL)searchOpenedList:(NSMutableArray<PathFindNode *> *)openedList
             closedList:(NSMutableArray<PathFindNode *> *)closedList
                     map:(PathFindMap *)map
                     end:(PathFindNode *)end {

    if (openedList.count == 0) {
        return YES;
    }
    PathFindNode *node = openedList.firstObject;
    if ([node isEqual:end]) {
        return YES;
    }
    
    BOOL isFinished = NO;
    for (MoveStep *step in map.allSteps) {
        NSString *key = [NSString stringWithFormat:@"%lu_%lu", (unsigned long)node.row + step.row, (unsigned long)node.col + step.col];
        PathFindNode *nearNode = map.nodesDic[key];
        if (nearNode && !nearNode.isObstacle && ![openedList containsObject:nearNode] && ![closedList containsObject:nearNode]) {
            nearNode.parent = node;
            nearNode.parentDirection = [PathFindMap parentDirectionWithStep:step];
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
