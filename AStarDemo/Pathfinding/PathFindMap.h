//
//  PathFindMap.h
//  IANLearn
//
//  Created by iMAC_HYH on 2018/5/4.
//  Copyright © 2018年 ian.Devs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, NodeDirection) {
    NodeDirectionNone        = 0,
    NodeDirectionTop         = 1 << 0,
    NodeDirectionLeftTop     = 1 << 1,
    NodeDirectionLeft        = 1 << 2,
    NodeDirectionLeftBottom  = 1 << 3,
    NodeDirectionBottom      = 1 << 4,
    NodeDirectionRightBottom = 1 << 5,
    NodeDirectionRight       = 1 << 6,
    NodeDirectionRightTop    = 1 << 7,
    NodeDirectionAll         = NodeDirectionTop | NodeDirectionLeftTop | NodeDirectionLeft | NodeDirectionLeftBottom | NodeDirectionBottom | NodeDirectionRightBottom | NodeDirectionRight | NodeDirectionRightTop
};

@interface MoveStep : NSObject

@property (nonatomic, assign) NSUInteger row;
@property (nonatomic, assign) NSUInteger col;
@property (nonatomic, assign) NSUInteger cost;

+ (MoveStep *)stepWithRow:(NSUInteger)row col:(NSUInteger)col cost:(NSUInteger)cost;

@end

#define Step(r,c,s) [MoveStep stepWithRow:r col:c cost:s]

@interface PathFindNode : NSObject

@property (nonatomic, strong) PathFindNode *parent;
@property (nonatomic, assign) NodeDirection parentDirection;
@property (nonatomic, assign) NSUInteger row;
@property (nonatomic, assign) NSUInteger col;
@property (nonatomic, assign) BOOL isObstacle;
@property (nonatomic, assign) NSUInteger costG;
@property (nonatomic, assign) NSUInteger costH;
@property (nonatomic, readonly) NSString *key;

+ (instancetype)nodeWithRow:(NSUInteger)row col:(NSUInteger)col;

@end

@interface PathFindMap : NSObject

@property NSArray<MoveStep *> *allSteps;
@property (nonatomic, readonly) NSDictionary<NSString *, PathFindNode *> *nodesDic;

@property (nonatomic, readonly) NSUInteger rowsCount;
@property (nonatomic, readonly) NSUInteger colsCount;

- (instancetype)initWithArray:(NSArray *)array;
+ (NodeDirection)parentDirectionWithStep:(MoveStep *)step;

@end
