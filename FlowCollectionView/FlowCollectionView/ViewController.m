//
//  ViewController.m
//  FlowCollectionView
//
//  Created by Toan Nguyen on 11/13/14.
//  Copyright (c) 2014 Toan Nguyen. All rights reserved.
//

#import "ViewController.h"
#import "WaveCollectionViewFlowLayout.h"
@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, WaveCollectionViewFlowLayoutDataSource>{
    int numberOfItems;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [(WaveCollectionViewFlowLayout *)self.collectionView.collectionViewLayout setFlowDynamic:YES];
    [(WaveCollectionViewFlowLayout *)self.collectionView.collectionViewLayout setDataSource:self];
    numberOfItems = 0;
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.collectionView performBatchUpdates:^{
        numberOfItems = 100;
        NSMutableArray *insertIndexPaths = [NSMutableArray array];
        for (int i = 0; i < numberOfItems; i++) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
            [insertIndexPaths addObject:path];
        }
        [self.collectionView insertItemsAtIndexPaths:insertIndexPaths];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return numberOfItems;
}

-(NSUInteger)collectionView:(UICollectionView *)theCollectionView layout:(WaveCollectionViewFlowLayout *)layout numberOfColumnsInSection:(NSUInteger)theSection{
    return 3;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(100, 100);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(50, 10, 5, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 20.0f;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionFooter) {
        return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footer" forIndexPath:indexPath];
    }else{
        return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
    }
}

#pragma mark - UICollectionViewDelegate



#pragma mark - UICollectinViewDelegateFlowLayout



#pragma mark -

@end
