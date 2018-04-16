//
//  YDPhotoDisplayViewController.m
//  TZImagePickerController
//
//  Created by mac on 13/4/18.
//  Copyright © 2018年 谭真. All rights reserved.
//

#import "YDPhotoDisplayViewController.h"
#import "TZAssetCell.h"
#import "TZAssetModel.h"
#import "TZImageManager.h"

@interface YDPhotoDisplayViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIImageView *displayImgView;

@end

@implementation YDPhotoDisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    [self.view addSubview:_collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 200;
}

//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
