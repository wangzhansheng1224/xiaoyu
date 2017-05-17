//
//  VideoManager.m
//  NemoSDKDemo
//
//  Created by 杨旭东 on 2016/12/22.
//  Copyright © 2016年 JackYang. All rights reserved.
//

#import "VideoManager.h"

@interface VideoManager ()

@property (nonatomic, strong) UIView *superView;

@property (nonatomic, strong) NemoBaseView *fullScreenView;

@property (nonatomic, strong) NemoVideo *localVideoView;

@property (nonatomic, strong) NemoImage *imageView;

@property (nonatomic, strong) NSMutableArray *currentVideos;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation VideoManager

+ (VideoManager *)sharedInstance{
    static VideoManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[VideoManager alloc] init];
        manager.currentVideos = [NSMutableArray array];
    });
    return manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
//        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f repeats:YES block:^(NSTimer * _Nonnull timer) {
//            
//        }];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(initVideo) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)initVideo{
    [_superView sendSubviewToBack:_fullScreenView];
}

- (void)dealloc{
    [_timer invalidate];
}

- (void)localView:(UIView *)superView{
    _superView = superView;
    
    [NemoVideo setUpVideo:^(NemoVideo *video) {
        video.origin(_superView.center, superView).fullScreen();
        video.layoutInfo(nil).frameRate(15).start();
        [video exchange:^(void (^swap)(NemoBaseView *)) {
            swap(_fullScreenView);
            _fullScreenView = video;
        }];
        _fullScreenView = _localVideoView = video;
    }];
}

- (void)audioMode:(BOOL)audio{
    if (audio) {
        [self pause];
    }else{
        [self reboot];
    }
    _localVideoView.mode(audio ? NemoCallMode_Audio : NemoCallMode_Movie);
    
}

- (void)pause{
    for (NemoVideo *video in _currentVideos) {
        video.mode(NemoCallMode_Audio);
    }
}

- (void)reboot{
    for (NemoVideo *video in _currentVideos) {
        video.mode(NemoCallMode_Movie);
    }
}

- (void)videosInSessionChanges:(NSArray *)videosInfo{
    NSMutableArray *videos = [self addedVideos:[NSMutableArray arrayWithArray:videosInfo]];
    
    if (_currentVideos.count + videos.count != 0) {
        _localVideoView.move(CGPointMake(15, _superView.bounds.size.width > _superView.bounds.size.height ? _superView.bounds.size.height - 95 : _superView.bounds.size.width - 95));
    }else{
        _localVideoView.fullScreen();
        _fullScreenView = _localVideoView;
    }
    
    [_currentVideos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (_imageView == nil) {
            NemoVideo *video = (NemoVideo *)obj;
            if (idx == 0) {
                video.fullScreen();
                _fullScreenView = video;
            }else{
                video.move(CGPointMake(15 + 130 * idx, _superView.bounds.size.width > _superView.bounds.size.height ? _superView.bounds.size.height - 95 : _superView.bounds.size.width - 95));
            }
        }else{
            NemoVideo *video = (NemoVideo *)obj;
            video.move(CGPointMake(15 + 130 * (idx + 1), _superView.bounds.size.width > _superView.bounds.size.height ? _superView.bounds.size.height - 95 : _superView.bounds.size.width - 95));
            _imageView.fullScreen();
            _fullScreenView = _imageView;
        }
    }];
    
    [videos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [NemoVideo setUpVideo:^(NemoVideo *video) {
            if (_imageView == nil) {
                if (_currentVideos.count + idx == 0) {
                    video.origin(CGPointZero, _superView).fullScreen();
                    _fullScreenView = video;
                }else{
                    video.origin(CGPointMake(15 + 130 * (_currentVideos.count + idx), _superView.bounds.size.width > _superView.bounds.size.height ? _superView.bounds.size.height - 95 : _superView.bounds.size.width - 95), _superView);
                }
            }else{
                video.origin(CGPointMake(15 + 130 * (_currentVideos.count + (idx + 1)), _superView.bounds.size.width > _superView.bounds.size.height ? _superView.bounds.size.height - 95 : _superView.bounds.size.width - 95), _superView);
                _imageView.fullScreen();
                _fullScreenView = _imageView;
            }
            video.layoutInfo(obj).frameRate(15).start();
            [video exchange:^(void (^swap)(NemoBaseView *)) {
                swap(_fullScreenView);
                _fullScreenView = video;
            }];
            
            [_currentVideos addObject:video];
        }];
    }];
}

- (NSMutableArray *)addedVideos:(NSMutableArray *)videos{
    NSMutableArray *currentVideos = [NSMutableArray arrayWithArray:_currentVideos];
    for (NemoVideo *video in currentVideos) {
        int index = video.existence(videos);
        if (index == -1) {
            if ([video isEqual:_fullScreenView]) {
                _fullScreenView = nil;
            }
            video.dismiss();
            [_currentVideos removeObject:video];
        }else{
            [videos removeObjectAtIndex:index];
        }
    }
    return videos;
}

- (void)shareImageStateChanged:(NemoContentState)state{
    if (state == NemoContentState_Receiving) {
        if (_imageView == nil) {
            [NemoImage setUpContent:^(NemoImage *content) {
                content.origin(CGPointMake(15 + 160 * _currentVideos.count, _superView.bounds.size.height - 115), _superView);
                content.start();
                _imageView = content;
                
                NemoBaseView *full = _fullScreenView;
                full.move(content.frame.origin);
                content.fullScreen();
                _fullScreenView = content;
                
                [content exchange:^(void (^swap)(NemoBaseView *)) {
                    swap(_fullScreenView);
                    _fullScreenView = content;
                }];
            }];
        }
    }else{
        NemoBaseView *base;
        for (UIView *view in _superView.subviews) {
            if ([view isKindOfClass:[NemoBaseView class]]) {
                base = (NemoBaseView *)view;
            }
        }
        _imageView.stop(base);
        _fullScreenView = base;
        _imageView = nil;
    }
}

- (void)dualStreamStateChanged:(NemoDualState)state{
    
}

- (void)clear{
    [_currentVideos removeAllObjects];
    [_superView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NemoBaseView class]]) {
            NemoBaseView *view = (NemoBaseView *)obj;
            view.dismiss();
        }
    }];
    _localVideoView = nil;
    _fullScreenView = nil;
    _imageView = nil;
}

@end

