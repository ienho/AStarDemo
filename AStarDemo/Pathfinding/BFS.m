//
//  BFS.m
//  IANLearn
//
//  Created by iMAC_HYH on 2018/5/7.
//  Copyright © 2018年 cdeledu. All rights reserved.
//

#import "BFS.h"
#import "AFindMap.h"

// 核心是从起始点开始遍历它的子节点，每一次遍历结束后都往更深一层递进
// 代码实现：
// 1.通过一个数组来保存遍历待遍历的节点，初始化将起始点加入到openedList
// 2.循环执行遍历，每次从openedList取出第一个节点进行遍历
// 3.遍历过后的节点添加到closedList，每次遍历某节点node时，将它node的子节点添加到openedList尾端
// 4.当结束点添加到closedList则搜索结束

@implementation BFS

+ (BOOL)findPathWithMap:(AFindMap *)map
                  start:(AStarNode *)start
                    end:(AStarNode *)end
              closedList:(NSMutableArray<AStarNode *> *)closedList
              openedList:(NSMutableArray<AStarNode *> *)openedList {

    if (!start || !end) {
        return NO;
    }
    
    StarCost cost;
    cost.costG = 0;
    cost.costH = 0;
    start.cost = cost;
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

+ (BOOL)searchOpenedList:(NSMutableArray<AStarNode *> *)openedList closedList:(NSMutableArray<AStarNode *> *)closedList map:(AFindMap *)map end:(AStarNode *)end {
    if (openedList.count == 0) {
        return YES;
    }
    
    BOOL isSearchFinish = NO;
    AStarNode *firstNode = openedList.firstObject;
    [openedList removeObjectAtIndex:0];
    if ([firstNode isEqual:end]) {
        isSearchFinish = YES;
    } else {
        for (MoveStep *step in map.allSteps) {
            NSString *key = [NSString stringWithFormat:@"%lu_%lu", (unsigned long)firstNode.row + step.row, (unsigned long)firstNode.col + step.col];
            AStarNode *nearNode = map.nodesDic[key];
            if (nearNode && !nearNode.isObstacle && ![closedList containsObject:nearNode]) {
                StarCost cost;
                cost.costG = firstNode.cost.costG + step.cost;
                if ([openedList containsObject:nearNode]) {
                    if (cost.costG < nearNode.cost.costG) {
                        nearNode.parent = firstNode;
                        nearNode.parentDirection = [AFindMap parentDirectionWithStep:step];
                        nearNode.cost = cost;
                    }
                } else {
                    if ([firstNode isEqual:end]) {
                        isSearchFinish = YES;
                        nearNode.parent = firstNode;
                        nearNode.parentDirection = [AFindMap parentDirectionWithStep:step];
                        nearNode.cost = cost;
                        [closedList addObject:nearNode];
                        break;
                    }
                    nearNode.parent = firstNode;
                    nearNode.parentDirection = [AFindMap parentDirectionWithStep:step];
                    nearNode.cost = cost;
                    [openedList addObject:nearNode];
                }
            }
        }
    }
    [closedList addObject:firstNode];
    
    return isSearchFinish;
}

@end
