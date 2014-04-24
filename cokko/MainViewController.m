static NSString *const PATH = @"burgers.json";

#import "MainViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RESTApi.h"
#import "HamburgerModel.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface MainViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *results;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) MBProgressHUD *progressHud;

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
    
    [self addProgressHud];
    
    RACSignal *resultsSignal = [[RESTApi sharedApi] getHamburgersFromPath:PATH];
    
    [resultsSignal subscribeNext:^(NSArray *results) {
        self.results = results;
    }];
    
    __weak typeof (self) weakSelf = self;
    
    [[RACObserve(self, results) deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        [weakSelf.tableView reloadData];
        [self.progressHud hide:YES];
    }];
}

- (void)addProgressHud {
    self.progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progressHud.mode = MBProgressHUDModeIndeterminate;
    self.progressHud.labelText = @"Loading burgers";
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
