//
//  AStar.m
//  IANLearn
//
//  Created by iMAC_HYH on 2018/5/7.
//  Copyright © 2018年 ian.Devs. All rights reserved.
//

#import "AStar.h"

@implementation AStar

+ (BOOL)findPathWithMap:(PathFindMap *)map
                  start:(PathFindNode *)start
                    end:(PathFindNode *)end
             closedList:(NSMutableArray<PathFindNode *> *)closedList
             openedList:(NSMutableArray<PathFindNode *> *)openedList {
    
    PathFindNode *cheapNode = start;
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

+ (PathFindNode *)findCheapNodeWithMap:(PathFindMap *)map
                             atNode:(PathFindNode *)node
                            endNode:(PathFindNode *)endNode
                        closedNodes:(NSMutableArray<PathFindNode *> *)closedNodes
                        openedNodes:(NSMutableArray<PathFindNode *> *)openedNodes {
    
    if (!node || !map.nodesDic.count) return nil;
    if (![map.nodesDic.allValues containsObject:node]) return nil;
    
    for (MoveStep *step in map.allSteps) {
        NSString *key = [NSString stringWithFormat:@"%lu_%lu", (unsigned long)node.row + step.row, (unsigned long)node.col + step.col];
        PathFindNode *nearNode = map.nodesDic[key];
        if (nearNode && !nearNode.isObstacle && ![closedNodes containsObject:nearNode]) {
            // calculate the cost
            NSUInteger tempCostG = node.costG + step.cost;
            if ([openedNodes containsObject:nearNode]) {
                if (tempCostG < nearNode.costG) {
                    nearNode.parent = node;
                    nearNode.costG = tempCostG;
                    nearNode.parentDirection = [PathFindMap parentDirectionWithStep:step];
                }
            } else {
                NSUInteger tempCostH = [AStar estimateCostBetweenNodeA:nearNode nodeB:endNode];
                nearNode.costG = tempCostG;
                nearNode.costG = tempCostH;
                nearNode.parent = node;
                nearNode.parentDirection = [PathFindMap parentDirectionWithStep:step];
                [openedNodes addObject:nearNode];
            }
        }
    }
    
    NSUInteger costMin = NSUIntegerMax;
    PathFindNode *cheapNode = nil;
    for (PathFindNode *tempNode in openedNodes) {
        if ([tempNode isEqual:endNode]) {
            cheapNode = endNode;
            break;
        }
        NSUInteger cost = tempNode.costG + tempNode.costH;
        if (cost < costMin) {
            costMin = cost;
            cheapNode = tempNode;
        }
    }
    
    return cheapNode;
}

// estimate the cost
+ (NSUInteger)estimateCostBetweenNodeA:(PathFindNode *)nodeA nodeB:(PathFindNode *)nodeB {
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
