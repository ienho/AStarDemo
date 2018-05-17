//
//  PathFindViewModel.h
//  IANLearn
//
//  Created by iMAC_HYH on 2018/5/3.
//  Copyright © 2018年 ian.Devs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PathFindMap.h"

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

@interface PathFindNodeViewModel : NSObject

@property (nonatomic, copy) typeof(void(^)(ANodeType nodeType)) typeChanged;
@property (nonatomic, copy) typeof(void(^)(NodeDirection arrowDirection)) directionChanged;
@property (nonatomic, assign) ANodeType nodeType;
@property (nonatomic, assign) NodeDirection arrowDirection;
@property (nonatomic, assign) NSUInteger row;
@property (nonatomic, assign) NSUInteger col;

@end

@interface PathFindViewModel : NSObject

@property (nonatomic, assign) AOperateType operateType;
@property (nonatomic, readonly) NSArray<NSArray<PathFindNodeViewModel *> *> *nodeViewModels;
@property (nonatomic, readonly) NSArray *mapArray;
@property (nonatomic, strong) PathFindNodeViewModel *start;
@property (nonatomic, strong) PathFindNodeViewModel *end;

- (instancetype)initWithSize:(NSUInteger)size;
- (instancetype)initWithArray:(NSArray *)array;

@end
