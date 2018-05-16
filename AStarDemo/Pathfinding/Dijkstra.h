//
//  Dijkstra.h
//  IANLearn
//
//  Created by iMAC_HYH on 2018/5/7.
//  Copyright © 2018年 cdeledu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFindMap.h"

@interface Dijkstra : NSObject

+ (BOOL)findPathWithMap:(AFindMap *)map
                  start:(AStarNode *)start
                    end:(AStarNode *)end
             closedList:(NSMutableArray<AStarNode *> *)closedList
             openedList:(NSMutableArray<AStarNode *> *)openedList;

@end
