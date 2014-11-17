//
//  FlowCollectionViewFlowLayout.m
//  FlowCollectionView
//
//  Created by Toan Nguyen on 11/13/14.
//  Copyright (c) 2014 Toan Nguyen. All rights reserved.
//

#import "WaveCollectionViewFlowLayout.h"
#import <UIKit/UIKit.h>

#define LINE_SPACING  10

@interface WaveCollectionViewFlowLayout()<UIScrollViewDelegate>{
    UIDynamicAnimator *_animator;
    
    
    
    //config collection view layout
    
    CGFloat _delta;
    NSMutableArray *_itemAttributes;
    NSMutableArray *_headerFooterAttributes;
    
    CGSize _contentSize;
    
    
}

@end


@implementation WaveCollectionViewFlowLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.flowDynamic = YES;
    }
    return self;
}


- (void)setFlowDynamic:(BOOL)flowDynamic{
    if ([UIDynamicAnimator class] == nil) {
        _flowDynamic = NO;
        return;
    }
    
    if (_flowDynamic != flowDynamic) {
        _flowDynamic = flowDynamic;
        if (!_flowDynamic) {
            [_animator removeAllBehaviors];
            _animator = nil;
        }else{
            _animator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
            
        }
    }
    
}
- (void)prepareLayout{
//    [_animator removeAllBehaviors];
    NSUInteger numberOfSections = [self.collectionView numberOfSections];
    _itemAttributes = [NSMutableArray array];
    _headerFooterAttributes = [NSMutableArray array];
    
    CGPoint sectionOrigin = CGPointZero;
    for (int i = 0; i < numberOfSections; i++) {
        sectionOrigin = [self prepareAttributesForSectionIndex:i sectionOriginPoint:sectionOrigin];
    }
    
    _contentSize = CGSizeMake(self.collectionView.frame.size.width, sectionOrigin.y);
    
}
- (CGPoint)prepareAttributesForSectionIndex:(NSUInteger)section sectionOriginPoint:(CGPoint)sectionOrigin{
    NSUInteger numberOfColumns = 1;
    if ([self.dataSource respondsToSelector:@selector(collectionView:layout:numberOfColumnsInSection:)]) {
        numberOfColumns = [self.dataSource collectionView:self.collectionView layout:self numberOfColumnsInSection:section];
    }
    
    UIEdgeInsets insets = self.sectionInset;
    if ([self.dataSource respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        insets = [self.dataSource collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
    }
    
    CGFloat minLineSpacing = 0;
    if ([self.dataSource respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
        minLineSpacing = [self.dataSource collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:section];
    }

    CGFloat sectionWidth = self.collectionView.frame.size.width;
    
    NSUInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];
    
    NSMutableArray *itemAttributesInSection = [NSMutableArray array];
    
    NSUInteger numberOfRows = (numberOfItems / numberOfColumns) + ((numberOfItems % numberOfColumns == 0) ? 0 : 1);
    
    CGFloat originY = insets.top + sectionOrigin.y;
    for (int r = 0; r < numberOfRows; r++) {
        NSMutableArray *itemAttributesInRow = [NSMutableArray array];
        CGFloat totalWidth = 0;
        CGFloat maxHeight = 0;
        for (int c = 0; c < numberOfColumns; c++) {
            NSUInteger idx = r * numberOfColumns + c;
            if (idx < numberOfItems) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:section];
                CGSize itemSize = self.itemSize;
                if ([self.dataSource respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
                    itemSize = [self.dataSource collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
                }
                UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                attribute.size = itemSize;
                totalWidth += itemSize.width;
                maxHeight = MAX(maxHeight, itemSize.height);
                
                
//                UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:attribute attachedToAnchor:attribute.center];
//                attachmentBehavior.length = 0.0f;
//                attachmentBehavior.damping = 2.0f;
//                attachmentBehavior.frequency = 2.0f;
//                [_animator addBehavior:attachmentBehavior];
                [itemAttributesInRow addObject:attribute];
            }else{
                break;
            }
        }//end for c
        
        //reposition Cells in row
        CGFloat interItemSpacing = (sectionWidth - totalWidth - insets.left - insets.right)/(numberOfColumns - 1);
        CGFloat originX = insets.left + sectionOrigin.x;
        for (UICollectionViewLayoutAttributes *obj in itemAttributesInRow) {
            obj.center = CGPointMake(originX + obj.size.width/2, originY + obj.size.height/2);
            originX += (obj.size.width + interItemSpacing);
        }
        [itemAttributesInSection addObjectsFromArray:itemAttributesInRow];
        originY += (maxHeight + minLineSpacing);
    }//end for r
    [_itemAttributes addObjectsFromArray:itemAttributesInSection];
    return CGPointMake(sectionOrigin.x, originY + insets.bottom);
}

- (CGSize)collectionViewContentSize{
    return _contentSize;
}
//
//- (void)updateCurrentVisibleRect{
//    CGPoint offset = [self.collectionView contentOffset];
//    CGRect rect = self.collectionView.frame;
//    _currentVisibleRect = CGRectMake(rect.origin.x + offset.x, rect.origin.y + offset.y, rect.size.width, rect.size.height);
//}

//- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath{
//    UICollectionViewLayoutAttributes *attribute = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
//    UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:attribute attachedToAnchor:attribute.center];
//    attachmentBehavior.length = 0.0f;
//    attachmentBehavior.damping = 2.0f;
//    attachmentBehavior.frequency = 2.0f;
//    [_animator addBehavior:attachmentBehavior];
//    attribute.center = CGPointMake(attribute.center.x, -attribute.center.y + self.collectionView.frame.size.height);
//    return attribute;
//}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSArray *array = [_itemAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *evaluatedObject, NSDictionary *bindings) {
        CGRect itemFrame = evaluatedObject.frame;
        return CGRectIntersectsRect(itemFrame, rect);
    }]];
    return array;
}
//- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path
//{
//    NSLog(@"layoutAttributesForItemAtIndexPath");
//    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:path];
//    return attributes;
//}

//- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
//    
//    UIScrollView *scrollView = self.collectionView;
//    _delta= newBounds.origin.y - scrollView.bounds.origin.y;
//    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
//    [_animator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *obj, NSUInteger idx, BOOL *stop) {
//        CGFloat yDistanceFromTouch = fabsf(touchLocation.y - obj.anchorPoint.y);
//        CGFloat scrollResistance = yDistanceFromTouch / 2000.0f;
//        
//        UICollectionViewLayoutAttributes *item = [obj.items firstObject];
//        CGPoint center = item.center;
//        
//        if (_delta< 0)
//            center.y += MAX(_delta, _delta*scrollResistance);
//        else
//            center.y += MIN(_delta, _delta*scrollResistance);
//        item.center = center;
//        [_animator updateItemUsingCurrentState:item];
//    }];
//    return [super shouldInvalidateLayoutForBoundsChange:newBounds];
//}



@end
