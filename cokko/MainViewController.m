static NSString *const PATH = @"burgers.json";

#import "MainViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RESTApi.h"
#import "HamburgerModel.h"

@interface MainViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *results;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    } 
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    RACSignal *resultsSignal = [[RESTApi sharedApi] getHamburgersFromPath:PATH];
    
    [resultsSignal subscribeNext:^(NSArray *results) {
        self.results = results;
    }];
    
    __weak typeof (self) weakSelf = self;
    
    [[RACObserve(self, results) deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        [weakSelf.tableView reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.results.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = ((HamburgerModel *)self.results[indexPath.row]).title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
