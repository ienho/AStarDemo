//
//  AStar.m
//  IANLearn
//
//  Created by iMAC_HYH on 2018/5/7.
//  Copyright © 2018年 cdeledu. All rights reserved.
//

#import "AStar.h"

@implementation AStar

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
        cheapNode = [AStar findCheapNodeWithMap:map
                                         atNode:cheapNode
                                        endNode:end
                                    closedNodes:closedList
                                    openedNodes:openedList];
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
                        closedNodes:(NSMutableArray<AStarNode *> *)closedNodes
                        openedNodes:(NSMutableArray<AStarNode *> *)openedNodes {
    
    if (!node || !map.nodesDic.count) return nil;
    if (![map.nodesDic.allValues containsObject:node]) return nil;
    
    for (MoveStep *step in map.allSteps) {
        NSString *key = [NSString stringWithFormat:@"%lu_%lu", (unsigned long)node.row + step.row, (unsigned long)node.col + step.col];
        AStarNode *nearNode = map.nodesDic[key];
        if (nearNode && !nearNode.isObstacle && ![closedNodes containsObject:nearNode]) {
            // calculate the cost
            NSUInteger tempCostG = node.cost.costG + step.cost;
            if ([openedNodes containsObject:nearNode]) {
                if (tempCostG < nearNode.cost.costG) {
                    nearNode.parent = node;
                    StarCost cost;
                    cost.costG = tempCostG;
                    cost.costH = nearNode.cost.costH;
                    nearNode.cost = cost;
                    nearNode.parentDirection = [AFindMap parentDirectionWithStep:step];
                }
            } else {
                NSUInteger tempCostH = [AStar estimateCostBetweenNodeA:nearNode nodeB:endNode];
                StarCost cost;
                cost.costG = tempCostG;
                cost.costH = tempCostH;
                nearNode.cost = cost;
                nearNode.parent = node;
                nearNode.parentDirection = [AFindMap parentDirectionWithStep:step];
                [openedNodes addObject:nearNode];
            }
        }
    }
    
    NSUInteger costMin = NSUIntegerMax;
    AStarNode *cheapNode = nil;
    for (AStarNode *tempNode in openedNodes) {
        if ([tempNode isEqual:endNode]) {
            cheapNode = endNode;
            break;
        }
        NSUInteger cost = tempNode.cost.costG + tempNode.cost.costH;
        if (cost < costMin) {
            costMin = cost;
            cheapNode = tempNode;
        }
    }
    
    return cheapNode;
}

// estimate the cost
+ (NSUInteger)estimateCostBetweenNodeA:(AStarNode *)nodeA nodeB:(AStarNode *)nodeB {
    NSUInteger colCost = nodeA.col > nodeB.col? (nodeA.col - nodeB.col) * 10 : (nodeB.col - nodeA.col) * 10;
    if (nodeA.row == nodeB.row) {
        return colCost;
    }
    NSUInteger rowCost = nodeA.row > nodeB.row? (nodeA.row - nodeB.row) * 10 : (nodeB.row - nodeA.row) * 10;
    if (nodeA.col == nodeB.col) {
        return rowCost;
    }
    
    NSUInteger costMin = MIN(colCost, rowCost) * 14;
    NSUInteger costLine = colCost > rowCost? (colCost - rowCost) : (rowCost - colCost);
    return costLine + costMin;
}

@end
