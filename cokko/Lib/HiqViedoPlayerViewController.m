static NSString *const HIQ_VIDEO_URL = @"https://www.youtube.com/watch?v=A-JVT0XHGkQ&list=UUoKazMwDmwZEA6P9Jl2RkpQ";

#import "HiqViedoPlayerViewController.h"
#import <HCYoutubeParser/HCYoutubeParser.h>

@interface HiqViedoPlayerViewController ()
@property (nonatomic, assign) NSTimeInterval videoPlayedDuration;
@property (nonatomic, weak) UIView *containerView;

@end

@implementation HiqViedoPlayerViewController

- (instancetype)init {
    if (self = [super init]) {
        __weak typeof(self) weakSelf = self;
        [HCYoutubeParser h264videosWithYoutubeURL:[NSURL URLWithString:HIQ_VIDEO_URL] completeBlock:^(NSDictionary *videoDictionary, NSError *error) {
            weakSelf.moviePlayer.contentURL = videoDictionary[@"hd720"];
        }];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    [self resumeVidePlayback];
}

- (void)addVideoPlayerToView:(UIView *)view {
    //TODO: loop or fade it out when done
    self.containerView = view;
    self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    
    [self.moviePlayer.view setFrame:CGRectMake(0, -14.0f, 320.0f, 220.0f)];
    [self.containerView addSubview:self.moviePlayer.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidFinishPlaying) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];;
}

- (void)videoDidFinishPlaying {
    [UIView animateWithDuration:1.0f animations:^{
        self.moviePlayer.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.moviePlayer.view removeFromSuperview];
    }];
}

- (void)resumeVidePlayback {
    if (self.videoPlayedDuration) {
        self.moviePlayer.initialPlaybackTime = self.videoPlayedDuration;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
