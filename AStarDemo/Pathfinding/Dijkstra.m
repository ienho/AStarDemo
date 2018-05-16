//
//  Dijkstra.m
//  IANLearn
//
//  Created by iMAC_HYH on 2018/5/7.
//  Copyright © 2018年 cdeledu. All rights reserved.
//

#import "Dijkstra.h"
#import "AFindMap.h"

// 核心是从起始点开始遍历它的子节点，每一次遍历结束后选择代价最小的节点进行下一次遍历
// 代码实现：
// 1.通过一个数组来保存遍历待遍历的节点，初始化将起始点加入到openedList
// 2.循环执行遍历，每次从openedList取出cose最小的节点进行遍历
// 3.遍历过后的节点添加到closedList，每次遍历某节点node时，将它node的子节点添加到openedList
// 4.遍历是当节点node的子节点childNode已经包含在openedList时，则针对childNode计算新的路径和原路径的cost, 如果新路径cost更小，则更新childNode的指向
// 动态规划 贪心策略 ，每次都选择最小路径，因为Dijkstra每次都是取的局部最短路径，所以Dijkstra算法必然是一种广度优先搜索算法；

@implementation Dijkstra

+ (BOOL)findPathWithMap:(AFindMap *)map
                  start:(AStarNode *)start
                    end:(AStarNode *)end
             closedList:(NSMutableArray<AStarNode *> *)closedList
             openedList:(NSMutableArray<AStarNode *> *)openedList {
    
    AStarNode *cheapNode = start;
    while (cheapNode && cheapNode != end) {
        if (cheapNode) {
            [openedList removeObject:cheapNode];
            [closedList addObject:cheapNode];
        }
        cheapNode = [Dijkstra findCheapNodeWithMap:map
                                            atNode:cheapNode
                                           endNode:end
                                        closedList:closedList
                                        openedList:openedList];
    }
    if (cheapNode) {
        [openedList removeObject:cheapNode];
        [closedList addObject:cheapNode];
    }
    
    return cheapNode == end;
}

+ (AStarNode *)findCheapNodeWithMap:(AFindMap *)map
                             atNode:(AStarNode *)node
                            endNode:(AStarNode *)endNode
                        closedList:(NSMutableArray<AStarNode *> *)closedList
                        openedList:(NSMutableArray<AStarNode *> *)openedList {
    
    if (!node || !map.nodesDic.count) return nil;
    if (![map.nodesDic.allValues containsObject:node]) return nil;
    
    for (MoveStep *step in map.allSteps) {
        NSString *key = [NSString stringWithFormat:@"%lu_%lu", (unsigned long)node.row + step.row, (unsigned long)node.col + step.col];
        AStarNode *nearNode = map.nodesDic[key];
        if (nearNode && !nearNode.isObstacle && ![closedList containsObject:nearNode]) {
            NSUInteger tempCostG = step.cost + node.cost.costG;
            if ([openedList containsObject:nearNode]) {
                if (tempCostG < nearNode.cost.costG) {
                    nearNode.parent = node;
                    StarCost cost;
                    cost.costG = tempCostG;
                    nearNode.cost = cost;
                    nearNode.parentDirection = [AFindMap parentDirectionWithStep:step];
                }
            } else {
                StarCost cost;
                cost.costG = tempCostG;
                nearNode.cost = cost;
                nearNode.parent = node;
                nearNode.parentDirection = [AFindMap parentDirectionWithStep:step];
                [openedList addObject:nearNode];
            }
        }
    }
    
    NSUInteger costMin = NSUIntegerMax;
    AStarNode *cheapNode = nil;
    for (AStarNode *tempNode in openedList) {
        NSUInteger cost = tempNode.cost.costG;
        if (cost < costMin) {
            costMin = cost;
            cheapNode = tempNode;
        }
    }
    
    return cheapNode;
}

@end
