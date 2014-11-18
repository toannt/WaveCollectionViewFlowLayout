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
    NSMutableArray *_dynamicIndexPaths;
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
            _dynamicIndexPaths = [NSMutableArray array];
            
        }
    }
    
}

- (void)prepareLayout{
    NSUInteger numberOfSections = [self.collectionView numberOfSections];
    _itemAttributes = [NSMutableArray array];
    _headerFooterAttributes = [NSMutableArray array];
    
    CGPoint sectionOrigin = CGPointZero;
    for (int i = 0; i < numberOfSections; i++) {
        sectionOrigin = [self prepareAttributesForSectionIndex:i sectionOriginPoint:sectionOrigin];
    }
    
    _contentSize = CGSizeMake(self.collectionView.frame.size.width, sectionOrigin.y);
    
    [self prepareDynamicsLayout];
}

- (void)prepareDynamicsLayout{
    CGRect visibleRect = CGRectInset((CGRect){.origin = self.collectionView.bounds.origin, .size = self.collectionView.frame.size}, -100, -100);
    
    NSArray *visibleItemAttributes = [_itemAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *evaluatedObject, NSDictionary *bindings) {
        return CGRectIntersectsRect(visibleRect, evaluatedObject.frame);
    }]];
    
    NSArray *visibleItemIndexPaths = [visibleItemAttributes valueForKey:@"indexPath"];
    
    NSArray *noLongerBehaviors = [_animator.behaviors filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIAttachmentBehavior *evaluatedObject, NSDictionary *bindings) {
        return ![visibleItemIndexPaths containsObject:[evaluatedObject.items[0] indexPath]];
    }]];
    
    
    [noLongerBehaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *obj, NSUInteger idx, BOOL *stop) {
        [_animator removeBehavior:obj];
        [_dynamicIndexPaths removeObject:[obj.items[0] indexPath]];
    }];
    
    
    NSArray *newlyVisibleItems = [visibleItemAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *evaluatedObject, NSDictionary *bindings) {
        return ![_dynamicIndexPaths containsObject:evaluatedObject.indexPath];
    }]];
    
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    [newlyVisibleItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes* obj, NSUInteger idx, BOOL *stop) {
        CGPoint center = obj.center;
        UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:obj attachedToAnchor:center];
        attachmentBehavior.length = 0.0f;
        attachmentBehavior.damping = 2.0f;
        attachmentBehavior.frequency = 1.0f;

        if (!CGPointEqualToPoint(CGPointZero, touchLocation)) {
            CGFloat distanceFromTouch = fabsf(touchLocation.y - attachmentBehavior.anchorPoint.y);
            CGFloat scrollResistance = distanceFromTouch / 1500.0f;
            
            if (_delta< 0)
                center.y += MAX(_delta, _delta*scrollResistance);
            else
                center.y += MIN(_delta, _delta*scrollResistance);
            obj.center = center;
            
        }
        [_animator addBehavior:attachmentBehavior];
        [_dynamicIndexPaths addObject:obj.indexPath];
    }];
    
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
                [itemAttributesInRow addObject:attribute];
            }else{
                break;
            }
        }//end for c
        
        if ([itemAttributesInRow count] < numberOfColumns) {
            NSInteger count = numberOfColumns - [itemAttributesInRow count];
            totalWidth += (count * [[itemAttributesInRow lastObject] size].width);
        }
        //reposition Cells in row
        CGFloat interItemSpacing = (sectionWidth - totalWidth - insets.left - insets.right)/(numberOfColumns - 1);
        CGFloat originX = insets.left + sectionOrigin.x;
        for (UICollectionViewLayoutAttributes *obj in itemAttributesInRow) {
            obj.center = CGPointMake(originX + obj.size.width/2, originY + obj.size.height/2);
            obj.frame = CGRectIntegral(obj.frame);
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

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSArray *array =  [_animator itemsInRect:rect];
    return array;
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
//    return [_animator layoutAttributesForCellAtIndexPath:indexPath];
    return [super layoutAttributesForItemAtIndexPath:indexPath];
}

//- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
//{
//    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
//    CGPoint center = attributes.center;
//    UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:attributes attachedToAnchor:center];
//    attachmentBehavior.length = 0.0f;
//    attachmentBehavior.damping = 2.0f;
//    attachmentBehavior.frequency = 1.0f;
//    
//    
//    center.y -= (itemIndexPath.row % 4 + 1) * 20;
//    attributes.center = center;
//    [_animator addBehavior:attachmentBehavior];
//    
//    return attributes;
//}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    
    UIScrollView *scrollView = self.collectionView;
    _delta= newBounds.origin.y - scrollView.bounds.origin.y;
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    [_animator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *obj, NSUInteger idx, BOOL *stop) {
        CGFloat yDistanceFromTouch = fabsf(touchLocation.y - obj.anchorPoint.y);
        CGFloat scrollResistance = yDistanceFromTouch / 1500.0f;
        
        UICollectionViewLayoutAttributes *item = [obj.items firstObject];
        CGPoint center = item.center;
        
        if (_delta< 0)
            center.y += MAX(_delta, _delta*scrollResistance);
        else
            center.y += MIN(_delta, _delta*scrollResistance);
        item.center = center;
        [_animator updateItemUsingCurrentState:item];
    }];
    return NO;
}


@end
