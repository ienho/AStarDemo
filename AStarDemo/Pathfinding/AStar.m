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
                NSUInteger tempCostH = [AStar estimateCostBetweenNodeA:nearNode nodeB:endNode map:map];
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
+ (NSUInteger)estimateCostBetweenNodeA:(PathFindNode *)nodeA nodeB:(PathFindNode *)nodeB map:(PathFindMap *)map {
    NSUInteger colCost = nodeA.col > nodeB.col? (nodeA.col - nodeB.col) : (nodeB.col - nodeA.col);
    if (nodeA.row == nodeB.row) {
        return colCost * 10;
    }
    NSUInteger rowCost = nodeA.row > nodeB.row? (nodeA.row - nodeB.row) : (nodeB.row - nodeA.row);
    if (nodeA.col == nodeB.col) {
        return rowCost * 10;
    }
    
    // top/left/bottom/right cost 10
    if (map.allSteps.count == 4) {
        return (colCost + rowCost) * 10;
    } else {
        // top/left/bottom/right cost 10
        // left-top/left-bottom/right-top/right-bottom cost 14
        NSUInteger costDiagonal =  MIN(colCost, rowCost);
        NSUInteger costLine = colCost > rowCost? (colCost - rowCost) : (rowCost - colCost);
        return costLine * 10 + costDiagonal * 14;
    }
}

@end
