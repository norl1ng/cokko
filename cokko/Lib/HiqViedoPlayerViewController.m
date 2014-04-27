static NSString *const HIQ_VIDEO_URL = @"https://www.youtube.com/watch?v=A-JVT0XHGkQ&list=UUoKazMwDmwZEA6P9Jl2RkpQ";

#import "HiqViedoPlayerViewController.h"
#import <HCYoutubeParser/HCYoutubeParser.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface HiqViedoPlayerViewController ()
@property (nonatomic, assign) NSTimeInterval videoPlayedDuration;
@property (nonatomic, weak) UIView *containerView;

@end

@implementation HiqViedoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.moviePlayer.contentURL = [NSURL URLWithString:[[HCYoutubeParser h264videosWithYoutubeURL:[NSURL URLWithString:HIQ_VIDEO_URL]] valueForKey:@"hd720"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:@"didEnterBackground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:@"didBecomeActive" object:nil];
}

- (void)applicationDidEnterBackground {
    self.videoPlayedDuration = self.moviePlayer.currentPlaybackTime;
    [self.moviePlayer pause];
}

- (void)applicationDidBecomeActive {
    // TODO: pause -> play doesn't work as expected. For now readding the videoplayer
    [self addVideoPlayerToView:self.containerView];
    [self resumeVideoPlayback];
}

- (void)addVideoPlayerToView:(UIView *)view {
    //TODO: loop or fade it out when done
    self.containerView = view;
    self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    
    [self.view setFrame:CGRectMake(0, -14.0f, 320.0f, 220.0f)];
    [self.containerView addSubview:self.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidFinishPlaying) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

- (void)videoDidFinishPlaying {
    [UIView animateWithDuration:1.0f animations:^{
        self.moviePlayer.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.moviePlayer.view removeFromSuperview];
    }];
}

- (void)resumeVideoPlayback {
    if (self.videoPlayedDuration) {
        self.moviePlayer.initialPlaybackTime = self.videoPlayedDuration;
    } else {
        [self.moviePlayer play];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
