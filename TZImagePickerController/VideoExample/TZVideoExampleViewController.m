//
//  TZVideoExampleViewController.m
//  TZImagePickerController
//
//  Created by mac on 11/4/18.
//  Copyright © 2018年 谭真. All rights reserved.
//

#import "TZVideoExampleViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>


@interface TZVideoExampleViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIButton *saveVideoBtn;
@property (nonatomic, strong) UIButton *openAlbumBtn;


@end

@implementation TZVideoExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [ UIColor grayColor];
    
    _openAlbumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _openAlbumBtn.frame = CGRectMake(100.f, 100.f, 100.f, 40.f);
    [self.view addSubview:_openAlbumBtn];
    [_openAlbumBtn addTarget:self action:@selector(onOpenAction:) forControlEvents:UIControlEventTouchUpInside];
    _openAlbumBtn.backgroundColor = [UIColor blueColor];
    [_openAlbumBtn setTitle:@"选择视频" forState:UIControlStateNormal];
    
    _saveVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveVideoBtn.frame = CGRectMake(100.f, 150.f, 100.f, 40.f);
    [self.view addSubview:_saveVideoBtn];
    [_saveVideoBtn addTarget:self action:@selector(onSaveAction:) forControlEvents:UIControlEventTouchUpInside];
    _saveVideoBtn.titleLabel.textColor = [UIColor purpleColor];
    _saveVideoBtn.backgroundColor = [UIColor redColor];
    [_saveVideoBtn setTitle:@"保存视频" forState:UIControlStateNormal];
}

- (void)onSaveAction:(UIButton *)sender {
    NSMutableArray *videoArray = [NSMutableArray array];

    NSArray<NSString *> *movs = [[NSBundle mainBundle] pathsForResourcesOfType:@"mp4" inDirectory:nil];
    [videoArray addObjectsFromArray:movs];
    for (NSString * item in videoArray) {
        if ([item hasSuffix:@"video.mp4"]) {
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(item)) {
                UISaveVideoAtPathToSavedPhotosAlbum(item, self, nil, NULL);
            }
        }
    }
}

- (void)onOpenAction:(UIButton *)sender {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
    
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    
    //视频最大时间
    ipc.videoMaximumDuration = 30;
    
    ipc.view.backgroundColor = [UIColor whiteColor];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.delegate = self;
    //只打开视频
    ipc.mediaTypes = @[(NSString *)kUTTypeMovie];
    
    //视频上传质量
    ipc.videoQuality = UIImagePickerControllerQualityTypeHigh;
    
    [self presentViewController:ipc animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *url = info[UIImagePickerControllerMediaURL];
        NSDictionary *videoDic = [self getLocalVideoSizeAndTimeWithSourcePath:url.absoluteString];
        int videoTime = [[videoDic valueForKey:@"duration"] intValue];
        NSUInteger limitTime = 30;
        
        __weak typeof (self) weakSelf = self;
        [self convertMovTypeIntoMp4TypeWithSourceUrl:url convertSuccess:^(NSURL *path) {
                [picker dismissViewControllerAnimated:YES completion:nil];
//                CZHChooseCoverController *chooseCover = [[CZHChooseCoverController alloc] init];
//                chooseCover.videoPath = path;
//                chooseCover.coverImageBlock = ^(UIImage *coverImage) {
//                self.coverImageView.image = coverImage;
//            };
//            [self presentViewController:chooseCover animated:YES completion:nil];
        }];
    }
}

- (NSDictionary *)getLocalVideoSizeAndTimeWithSourcePath:(NSString *)path{
    AVURLAsset * asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
    CMTime   time = [asset duration];
    int seconds = ceil(time.value/time.timescale);
    
    NSInteger fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil].fileSize;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"size"] = @(fileSize);
    dic[@"duration"] = @(seconds);
    return dic;
}

- (void)convertMovTypeIntoMp4TypeWithSourceUrl:(NSURL *)sourceUrl convertSuccess:(void (^)(NSURL *path))convertSuccess {
    
    [self createVideoFolderIfNotExist];
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:sourceUrl options:nil];
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    //    BWJLog(@"%@",compatiblePresets);
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
        
        
        NSString * resultPath = [self getVideoMergeFilePathString];
        
        NSLog(@"resultPath = %@",resultPath);
        
        
        exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
        
        exportSession.outputFileType = AVFileTypeMPEG4;
        
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                    if (convertSuccess) {
                        convertSuccess([NSURL fileURLWithPath:resultPath]);
                    }
                } else {
                    
                    
                }
            });
            
        }];
    }
}

- (void)createVideoFolderIfNotExist
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSString *folderPath = [path stringByAppendingPathComponent:@"videoFolder"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isDirExist = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    
    if(!(isDirExist && isDir))
    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            
        }
    }
}

- (NSString *)getVideoMergeFilePathString
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    path = [path stringByAppendingPathComponent:@"video_folder"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *fileName = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@"merge.mp4"];
    
    return fileName;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
