//
//  ViewController.m
//  SoundSyncTest
//
//  Created by Dustin Laverick on 01/01/2013.
//  Copyright (c) 2013 Iterator Ltd. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()

@property (strong, atomic) AVPlayer *player;
@property (strong, atomic) AVPlayerItem *playerItem;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
- (IBAction)playButtonTapped:(id)sender;
@end

static void *PlaybackManagerPlayerItemStatusContext = &PlaybackManagerPlayerItemStatusContext;

@implementation ViewController


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( context == PlaybackManagerPlayerItemStatusContext)
    {
//        NSLog(@"KVO Observation: %@", change);
//        NSLog(@"self.player.currentItem.status = %i", self.player.currentItem.status);
//        NSLog(@"self.player.status = %i", self.player.status);

        if (self.player.status == AVPlayerStatusReadyToPlay && self.player.currentItem.status == AVPlayerItemStatusReadyToPlay)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.player prerollAtRate:1.0f completionHandler:^(BOOL finished) {
                    
                    self.playButton.enabled = finished;
                }];
            });
        }
    }
 }




- (void)viewDidLoad
{
    [super viewDidLoad];
   
    
    NSURL *url00 = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"2" ofType:@"wav"]];
    AVURLAsset *urlAsset00 =  [AVURLAsset URLAssetWithURL:url00 options:@{AVURLAssetPreferPreciseDurationAndTimingKey : @YES}];

    NSURL *url04 = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"4" ofType:@"wav"]];
    AVURLAsset *urlAsset04 =  [AVURLAsset URLAssetWithURL:url04 options:@{AVURLAssetPreferPreciseDurationAndTimingKey : @YES}];

    
    
    [self addObserver:self
           forKeyPath:@"player.currentItem.status"
              options:NSKeyValueObservingOptionNew
              context:PlaybackManagerPlayerItemStatusContext];

    [self addObserver:self
           forKeyPath:@"player.status"
              options:NSKeyValueObservingOptionNew
              context:PlaybackManagerPlayerItemStatusContext];

    
    
    __block typeof(self) _blockself = self;
    
    [urlAsset00 loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        [urlAsset04 loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
    
            AVMutableComposition *comp = [AVMutableComposition composition];
            AVMutableCompositionTrack *track1 = [comp addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            
            [track1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(4, 4))
                            ofTrack:[urlAsset00.tracks lastObject]
                             atTime:kCMTimeZero
                              error:nil];

            [track1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(4, 4))
                            ofTrack:[urlAsset00.tracks lastObject]
                             atTime:CMTimeMake(8, 4)
                              error:nil];

    
            AVMutableCompositionTrack *track2 = [comp addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            
            [track2 insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(4, 4))
                            ofTrack:[urlAsset04.tracks lastObject]
                             atTime:kCMTimeZero
                              error:nil];
    
            [track2 insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMake(4, 4))
                            ofTrack:[urlAsset04.tracks lastObject]
                             atTime:CMTimeMake(8, 4)
                              error:nil];
    
    
            [comp loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
                _blockself.player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:comp]];
    
            }];
        }];
    }];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playButtonTapped:(id)sender {
    
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [self.player play];
    }];
}
@end
