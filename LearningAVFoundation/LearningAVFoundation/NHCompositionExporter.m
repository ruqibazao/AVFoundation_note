//
//  NHCompositionExporter.m
//  LearningAVFoundation
//
//  Created by nenhall on 2020/2/18.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import "NHCompositionExporter.h"
#import <UIKit/UIKit.h>

@interface NHCompositionExporter ()
@property (nonatomic, strong) id<NHComposition> composition;
@property (nonatomic, strong) AVAssetExportSession *exportSession;
@property (nonatomic, copy) void (^exportCompletion) (void);
@end

@implementation NHCompositionExporter

- (instancetype)initWithComposition:(id<NHComposition>)composition {
    self = [super init];
    if (self) {
        _composition = composition;
    }
    return self;
}

- (void)beginExport {
    self.exportSession = [self.composition makeExportable];
    self.exportSession.outputURL = [self exportURL];
    self.exportSession.outputFileType = AVFileTypeMPEG4;
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.exportCompletion) {
                self.exportCompletion();
            }
            AVAssetExportSessionStatus status = self.exportSession.status;
            if (status == AVAssetExportSessionStatusCompleted) {
                [self writeExportedVideoToAssetLibrary];
                NSLog(@"保存到相册成功");
            } else {
                NSString *message = @"Expoert Failed";
                               [[[UIAlertView alloc] initWithTitle:message message:message delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:@"enter", nil] show];
            }
        });
    }];
    self.exporting = YES;
    [self monitorExportProgress];
}

- (void)exportCompletionHandler:(void (^)(void))handler {
    _exportCompletion = handler;
}

- (void)writeExportedVideoToAssetLibrary {
    NSURL *exportURL = self.exportSession.outputURL;
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:exportURL]) {
        [library writeVideoAtPathToSavedPhotosAlbum:exportURL completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                NSString *message = @"Unable to write to Photos library";
                [[[UIAlertView alloc] initWithTitle:message message:message delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:@"enter", nil] show];
            }
            [[NSFileManager defaultManager] removeItemAtURL:exportURL error:nil];
        }];
    } else {
        NSLog(@"video could not be exported to the assets library");
    }
}

- (void)monitorExportProgress {
    double delayInSeconds = 0.1;
    int64_t delta = (int64_t)delayInSeconds * NSEC_PER_SEC;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delta);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        AVAssetExportSessionStatus status = self.exportSession.status;
        if (status == AVAssetExportSessionStatusExporting) {
            self.progress = self.exportSession.progress;
            NSLog(@"progress：%.02f", self.progress);
            [self monitorExportProgress];
        } else {
            self.exporting = NO;
        }
    });
}

- (NSURL *)exportURL {
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(),@"freeWriter.m4v"]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    }
    return url;
}

@end
