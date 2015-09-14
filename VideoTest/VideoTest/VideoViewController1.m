//
//  VideoViewController.m
//  VideoTest
//
//  Created by lkk on 13-11-25.
//  Copyright (c) 2013年 lkk. All rights reserved.
//

#import "VideoViewController1.h"
#import "ASIHTTPRequest.h"
#import "AudioButton.h"
#import <MediaPlayer/MediaPlayer.h>

@interface VideoViewController ()
{
    InfiniteScrollPicker *isp;
    InfiniteScrollPicker *isp2;
    InfiniteScrollPicker *isp3;
    MPMoviePlayerController *player;
}


@end

@implementation VideoViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation == UIInterfaceOrientationMaskLandscapeLeft);
    return (interfaceOrientation != UIInterfaceOrientationLandscapeLeft ||
            
            interfaceOrientation != UIInterfaceOrientationLandscapeRight );
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //视频播放结束通知
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoFinished) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoFinished) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReadyPlay:) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dosomgthing:) name:MPMoviePlayerLoadStateDidChangeNotification object:self];
        
       // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dosomgthing) name:MPMovieNaturalSizeAvailableNotification object:nil];
       
    }
    return self;
}

-(void)dosomgthing:(NSNotification*)notification
{
//    NSLog(@"2222");
//    MPMoviePlayerController *moviePlayer = notification.object;
//        MPMovieLoadState loadState = moviePlayer.loadState;
//     
//        if(loadState == MPMovieLoadStateUnknown) {
//                moviePlayer.contentURL = [NSURL fileURLWithPath:videoPath]
//                [moviePlayer prepareToPlay];
//            }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor greenColor];
    
    NSMutableArray *set3 = [[NSMutableArray alloc] init];
    for (int i = 0; i < 20; i++) {
        [set3 addObject:[UIImage imageNamed:[NSString stringWithFormat:@"s3_%d.jpeg", i]]];
    }
    
    self.view.frame = [[UIScreen mainScreen]bounds];
    
    isp3 = [[InfiniteScrollPicker alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
    [isp3 setImageAry:set3];
    [isp setItemSize:CGSizeMake(10, 10)];
    [isp3 setHeightOffset:40];
    [isp3 setPositionRatio:2];
    [isp3 setAlphaOfobjs:0.8];
    [self.view addSubview:isp3];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)infiniteScrollPicker:(InfiniteScrollPicker *)infiniteScrollPicker didSelectAtImage:(UIImage *)image
{
    [self videoPlay];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)videoPlay{
    
    AudioButton *musicBt = [[AudioButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width/8, self.view.frame.size.width/8)];
    //[musicBt addTarget:self action:@selector(videoPlay) forControlEvents:UIControlEventTouchUpInside];
    [musicBt setTag:1];
    [self.view addSubview:musicBt];
    
    NSString *webPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Private Documents/Temp"];
    NSString *cachePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Private Documents/Cache"];
    NSLog(@"%@",webPath);
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:cachePath])
    {
        [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![fileManager fileExistsAtPath:[cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"vedio.mp4"]]]) {
//        MPMoviePlayerViewController *playerViewController = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL fileURLWithPath:[cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"vedio.mp4"]]]];
//        [self presentMoviePlayerViewControllerAnimated:playerViewController];
        
        player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:[cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"vedio.mp4"]]]];
//        // 设置播放器的大小(16:9)
       [player.view setFrame:self.view.bounds];
        //设置样式，让播放器影藏工具条
        [player setControlStyle:MPMovieControlStyleFullscreen];
        //[player prepareToPlay];
        //[player setFullscreen:YES];
        // 将播放器视图添加到根视图
        [self.view addSubview:player.view];
        [player play];

        videoRequest = nil;
    }else{
        ASIHTTPRequest *request=[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"]];
        AudioButton *musicBt = (AudioButton *)[self.view viewWithTag:1];
        [musicBt startSpin];
        //下载完存储目录
        [request setDownloadDestinationPath:[cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"vedio.mp4"]]];
        //临时存储目录
        [request setTemporaryFileDownloadPath:[webPath stringByAppendingPathComponent:[NSString stringWithFormat:@"vedio.mp4"]]];
        [request setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {
            [musicBt stopSpin];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setDouble:total forKey:@"file_length"];
            Recordull += size;//Recordull全局变量，记录已下载的文件的大小
            if (!isPlay&&Recordull > 400000) {
                isPlay = !isPlay;
                [self playVideo];
            }
        }];
        //断点续载
        [request setAllowResumeForFileDownloads:YES];
        [request startAsynchronous];
        videoRequest = request;
    }
}
- (void)playVideo{
    
    player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"]];
    [player.view setFrame:self.view.bounds];
    //设置样式，让播放器影藏工具条
    [player setControlStyle:MPMovieControlStyleFullscreen];
    [player prepareToPlay];
    [player setFullscreen:YES];
//    player.currentPlaybackRate = 1.0;
//    player.currentPlaybackTime = 10;
    // 将播放器视图添加到根视图
    [self.view addSubview:player.view];
    
    //MPMoviePlayerViewController *playerViewController =[[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:@"http://127.0.0.1:12345/vedio.mp4"]];
//    MPMoviePlayerViewController *playerViewController =[[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"]];
//    playerViewController.moviePlayer.movieSourceType=MPMovieSourceTypeFile;
//    NSLog(@"当前时长：%f\n总时长：%f\n",playerViewController.moviePlayer.playableDuration,playerViewController.moviePlayer.duration);
//
//   [self presentMoviePlayerViewControllerAnimated:playerViewController];
    
}

-(void)onReadyPlay:(NSNotification *)notify
{
    NSLog(@"go");
    [player play];
}

- (void)videoFinished{
    NSLog(@"Done");
    if (player.view!=nil) {
       [player.view removeFromSuperview];
    }
    AudioButton *musicBt = (AudioButton *)[self.view viewWithTag:1];
    if (musicBt!=nil)
    {
        [musicBt removeFromSuperview];
    }
    
    if (videoRequest) {
        isPlay = !isPlay;
        [videoRequest clearDelegatesAndCancel];
        videoRequest = nil;
    }
}
@end
