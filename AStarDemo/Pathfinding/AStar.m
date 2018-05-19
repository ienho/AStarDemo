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
    
    [openedList addObject:start];
    PathFindNode *cheapNode = [AStar findCheapNodeWithEndNode:end closedNodes:closedList openedNodes:openedList];
    do {
        [AStar searchAtNode:cheapNode
                        map:map
                    endNode:end
                closedNodes:closedList
                openedNodes:openedList];
        cheapNode = [AStar findCheapNodeWithEndNode:end closedNodes:closedList openedNodes:openedList];
    } while (![cheapNode isEqual:end] && openedList.count != 0);
    
    return cheapNode == end;
}

+ (void)searchAtNode:(PathFindNode *)node
                 map:(PathFindMap *)map
             endNode:(PathFindNode *)endNode
         closedNodes:(NSMutableArray<PathFindNode *> *)closedNodes
         openedNodes:(NSMutableArray<PathFindNode *> *)openedNodes {

    if (!node || !map.nodesDic.count) return;
    if (![map.nodesDic.allValues containsObject:node]) return;
  
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
                nearNode.costH = tempCostH;
                nearNode.parent = node;
                nearNode.parentDirection = [PathFindMap parentDirectionWithStep:step];
                [openedNodes addObject:nearNode];
            }
        }
    }
    
    [openedNodes removeObject:node];
    [closedNodes addObject:node];
}

+ (PathFindNode *)findCheapNodeWithEndNode:(PathFindNode *)endNode
                               closedNodes:(NSMutableArray<PathFindNode *> *)closedNodes
                               openedNodes:(NSMutableArray<PathFindNode *> *)openedNodes {
    NSUInteger costMin = NSUIntegerMax;
    PathFindNode *cheapNode = nil;
    for (PathFindNode *tempNode in openedNodes) {
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
