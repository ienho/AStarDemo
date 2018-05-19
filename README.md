# hello, A~* 寻路算法!

> 寻路算法是游戏中经常用到的算法之一，而这其中`A~*` 算法大概是我们最耳熟的寻路算法了，下面我们会通过`A~*` 算法与广度优先遍历搜索和深度优先遍历搜索的寻路过程的比较来了解`A~*`算法的思想

Demo演示代码可以点这→ [Demo](https://github.com/ienho/AStarDemo)

### BFS
广度优先遍历的过程就是以起始点为中心开始向周围搜索，每次搜索完一层，继续往更远一层搜索

![从蓝点开始向外一层层扩散搜索](https://upload-images.jianshu.io/upload_images/2750155-aada2b5209d24d11.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/360)


因为`BFS`是一层层向外搜索，所以它总是能找到最短路径，因为它的路径不会绕道更远的地方再折回来。但是很明显我们肉眼一下就能看出的最短路径，用`BFS`搜索则需要遍历那么多节点。


### DFS
深度优先遍历的过程就是从起始点开始一直向远处搜索，直到搜索到边界，然后再往回寻找另外一条分支

![从蓝点开始一直沿着相邻节点搜索](https://upload-images.jianshu.io/upload_images/2750155-d119115d86f99780.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/360)

从图中的`DFS`的最终路径可以看出来，`DFS`搜索出来的路径并不是最短路径，所以`DFS`路径搜索不能保证搜索到的是最短路径，除非你将整个地图全部遍历，记录下所有的可达路径，然后选择最短的，但是这个过程会非常的耗时间。`DFS`确实不会去走捷径，它总是一条路走到黑。

### A~*
A~* 算法的关键是每走的一步都是选择最短的估价路径节点。`A~*`的搜索过程既不会像`BFS`那样沿着周围海量的搜索，也不会像`DFS`那样可能会绕弯子，因为它每一步都会计算当前到达终点的估价值，所以它往远处搜索是启发式的搜索，通过估价值来启发往哪个方向走
![每一次都选择周围的看起来距离终点最近的点](https://upload-images.jianshu.io/upload_images/2750155-a30d5a8e40724552.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/360)

图中可以看到A~*每走一步都会去遍历当前点周围路径，然后选择最短(估价最短)的路径往下走。因为估价一般都是假定当前点到终点最短的路径上没有障碍物，一旦这个路径上有障碍物，那么该条路径在搜索到障碍物的时候会发生转向（放弃原有的路径），如下图所示，估价值最短的路径一直是从蓝点到红点垂直往下的路径，当往下走到发现下方是障碍以后，就会从当前路径之外的路径中寻找估价最短的

![Simulator Screen Shot - iPhone 6s Plus - 2018-05-19 at 12.59.34.png](https://upload-images.jianshu.io/upload_images/2750155-5a540720a8f6f594.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/360)

###  A~*算法实现

###### 算法描述
start：起始点
end：终点
costG：该节点按照搜索路径到达起始点的代价；
costH：该节点到达终点end的估计值
openedList：待搜索序列
closedList：已经过的序列

1. 将起始点start加入到待搜索序列openedList中
2. 从openedList选择一个代价最低的节点cheapest（期初cheapest是起始点）如果该节点是终点则搜索成功；
3. 遍历cheapest的所有邻近节点near；
4.  - 如果near已经走过，即包含在closedList中，则将略过它；
     - 如果near已经遍历过，即包含在openedList中，则比较near之前遍历的路径到起始点的距离和near按照经过cheapest到达起始点的距离，如果新的路径起始点更低，则更新near的costG值。
     - 如果near不包含在openedList和closedList中，则计算该节点按照搜索的路径到达起始点的距离costG，计算该节点到达终点的估计距离costH，并更新该节点的这两个值，将near加入到openedList中
5. cheapest节点搜索完以后，将cheapest从openedList移除，并加入到closedList中；
重复2-5的过程；

###### A~* 算法的估价计算包括2部分
- 1. 当前点到起始的实际距离costG；
- 2. 当前点到终点的估计距离，这个距离是通过坐标的一些运算来的，因为它忽略代理路径上的障碍物，所以并不一定是最短的路径距离值, costH；

###### 关键代码实现：
使用二维数组来表示整个地图
```
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

// 遍历当前节点的子节点
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

// 查找估价值最短的节点
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
```

算法稳定性
从上面的示例图中可以看到算法效率`A~*` > `BFS` >`DFS`
如果是用来寻找最短路径的话`DFS`是不适合的，
但也有些极端情况下`DFS`却是遍历最少的

![Simulator Screen Shot - iPhone 6s Plus - 2018-05-19 at 16.33.53.png](https://upload-images.jianshu.io/upload_images/2750155-f1ac62a37a26bed5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/360)

![Simulator Screen Shot - iPhone 6s Plus - 2018-05-19 at 16.33.54.png](https://upload-images.jianshu.io/upload_images/2750155-92ffeafe852c0fa4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/360)

![Simulator Screen Shot - iPhone 6s Plus - 2018-05-19 at 16.33.55.png](https://upload-images.jianshu.io/upload_images/2750155-a5dd1e8380acff89.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/360)

> 实际应用中这些算法都会经过优化定制来提高效率
广度优先搜索可以采用双向广度优先搜索，最终是两块搜索区域重叠则搜索完成，这样的话可以减少很多次的遍历；
`A~*`算法可以针对估价函数进行定制，比如估价函数添加一下预判可以让搜索路径比较早的发现障碍物减少不必要的搜索；

### 简单迷宫测试
在16x16的网格地图中我编辑了一个迷宫，下面是A~*算法的的寻路情况
![](https://upload-images.jianshu.io/upload_images/2750155-c76549a45af68741.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/360)

![`A~*`迷宫路径](https://upload-images.jianshu.io/upload_images/2750155-86cce634ae9cebf0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/360)

Demo代码git地址: [https://github.com/ienho/AStarDemo](https://github.com/ienho/AStarDemo)
