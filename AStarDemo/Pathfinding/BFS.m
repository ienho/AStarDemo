//
//  BFS.m
//  IANLearn
//
//  Created by iMAC_HYH on 2018/5/7.
//  Copyright © 2018年 ian.Devs. All rights reserved.
//

#import "BFS.h"
#import "PathFindMap.h"

// 核心是从起始点开始遍历它的子节点，每一次遍历结束后都往更深一层递进
// 代码实现：
// 1.通过一个数组来保存遍历待遍历的节点，初始化将起始点加入到openedList
// 2.循环执行遍历，每次从openedList取出第一个节点进行遍历
// 3.遍历过后的节点添加到closedList，每次遍历某节点node时，将它node的子节点添加到openedList尾端
// 4.当结束点添加到closedList则搜索结束

@implementation BFS

+ (BOOL)findPathWithMap:(PathFindMap *)map
                  start:(PathFindNode *)start
                    end:(PathFindNode *)end
              closedList:(NSMutableArray<PathFindNode *> *)closedList
              openedList:(NSMutableArray<PathFindNode *> *)openedList {

    if (!start || !end) {
        return NO;
    }
    
    [openedList addObject:start];
    
    BOOL isFinish = NO;
    do {
       isFinish = [BFS searchOpenedList:openedList closedList:closedList map:map end:end];
    } while (!isFinish);
    
    if ([closedList containsObject:end]) {
        return YES;
    }
    return NO;
}

+ (BOOL)searchOpenedList:(NSMutableArray<PathFindNode *> *)openedList closedList:(NSMutableArray<PathFindNode *> *)closedList map:(PathFindMap *)map end:(PathFindNode *)end {
    if (openedList.count == 0) {
        return YES;
    }
    
    BOOL isSearchFinish = NO;
    PathFindNode *firstNode = openedList.firstObject;
    [openedList removeObjectAtIndex:0];
    if ([firstNode isEqual:end]) {
        isSearchFinish = YES;
    } else {
        for (MoveStep *step in map.allSteps) {
            NSString *key = [NSString stringWithFormat:@"%lu_%lu", (unsigned long)firstNode.row + step.row, (unsigned long)firstNode.col + step.col];
            PathFindNode *nearNode = map.nodesDic[key];
            if (nearNode && !nearNode.isObstacle && ![closedList containsObject:nearNode]) {
                NSUInteger cost = firstNode.costG + step.cost;
                if ([openedList containsObject:nearNode]) {
                    if (cost < nearNode.costG) {
                        nearNode.parent = firstNode;
                        nearNode.parentDirection = [PathFindMap parentDirectionWithStep:step];
                        nearNode.costG = cost;
                    }
                } else {
                    if ([firstNode isEqual:end]) {
                        isSearchFinish = YES;
                        nearNode.parent = firstNode;
                        nearNode.parentDirection = [PathFindMap parentDirectionWithStep:step];
                        nearNode.costG = cost;
                        [closedList addObject:nearNode];
                        break;
                    }
                    nearNode.parent = firstNode;
                    nearNode.parentDirection = [PathFindMap parentDirectionWithStep:step];
                    nearNode.costG = cost;
                    [openedList addObject:nearNode];
                }
            }
        }
    }
    [closedList addObject:firstNode];
    
    return isSearchFinish;
}

@end
