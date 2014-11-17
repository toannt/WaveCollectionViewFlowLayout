//
//  FlowCollectionViewFlowLayout.h
//  FlowCollectionView
//
//  Created by Toan Nguyen on 11/13/14.
//  Copyright (c) 2014 Toan Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>


@class WaveCollectionViewFlowLayout;

typedef enum {
    WaveCollectionDirectionLeftToRight = 1 << 0,
    WaveCollectionDirectionRightToLeft = 1 << 1,
    WaveCollectionDirectionBottomToTop = 1 << 2,
    WaveCollectionDirectionTopToBottom = 1 << 3
} WaveCollectionDirection;


@protocol WaveCollectionViewFlowLayoutDataSource <UICollectionViewDelegateFlowLayout>

- (NSUInteger) collectionView:(UICollectionView *) theCollectionView layout:(WaveCollectionViewFlowLayout *)layout numberOfColumnsInSection:(NSUInteger) theSection;


@end


@interface WaveCollectionViewFlowLayout : UICollectionViewFlowLayout
@property (nonatomic, weak) id<WaveCollectionViewFlowLayoutDataSource> dataSource;
@property (nonatomic, assign) WaveCollectionDirection direction;
@property (nonatomic, assign) BOOL flowDynamic;
@end
