//
//  AStarViewModel.h
//  IANLearn
//
//  Created by iMAC_HYH on 2018/5/3.
//  Copyright © 2018年 cdeledu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFindMap.h"

typedef NS_ENUM(NSInteger, ANodeType) {
    ANodeTypeEmpty,
    ANodeTypeStart,
    ANodeTypeEnd,
    ANodeTypeObstancle,
    ANodeTypePath,
    ANodeTypeSearch
};

typedef NS_ENUM(NSInteger, AOperateType) {
    AOperateTypeSetStart,
    AOperateTypeSetEnd,
    AOperateTypeSetObstancle
};

@interface ANodeViewModel : NSObject

@property (nonatomic, copy) typeof(void(^)(ANodeType nodeType)) typeChanged;
@property (nonatomic, copy) typeof(void(^)(NodeDirection arrowDirection)) directionChanged;
@property (nonatomic, assign) ANodeType nodeType;
@property (nonatomic, assign) NodeDirection arrowDirection;
@property (nonatomic, assign) NSUInteger row;
@property (nonatomic, assign) NSUInteger col;

@end

@interface AStarViewModel : NSObject

@property (nonatomic, assign) AOperateType operateType;
@property (nonatomic, readonly) NSArray<NSArray<ANodeViewModel *> *> *nodeViewModels;
@property (nonatomic, readonly) NSArray *mapArray;
@property (nonatomic, strong) ANodeViewModel *start;
@property (nonatomic, strong) ANodeViewModel *end;

- (instancetype)initWithArray:(NSArray *)array;

@end
