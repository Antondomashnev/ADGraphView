//
//  ViewController.m
//  SCGraphView
//
//  Created by Anton Domashnev on 25.02.13.
//  Copyright (c) 2013 Anton Domashnev. All rights reserved.
//

#import "ViewController.h"
#import "GraphDataObject.h"
#import "GraphView.h"
#import "MBProgressHUD.h"

@interface ViewController ()<GraphViewDelegate>

@property (nonatomic, strong) GraphView *graphView;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation ViewController

- (NSInteger)randomBetweenFirst:(int)start andSecond:(int)end{
    
    return arc4random_uniform(end - start) + start;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"ADGraphView", @"");
	
    [self addGraphView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark GraphView

- (void)addGraphView{
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = NSLocalizedString(@"Loading graph data...", @"");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970: 1351036800];
        NSDate *endDate = [NSDate dateWithTimeIntervalSince1970: 1382096000];
        
        NSArray *graphObjects = [NSArray arrayWithArray: [GraphDataObject randomGraphDataObjectsArray:2000 startDate:startDate endDate:endDate]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if([graphObjects count] > 0){

                self.graphView = [[GraphView alloc] initWithFrame:DEFAULT_GRAPH_VIEW_FRAME objectsArray:graphObjects startDate:startDate endDate:endDate delegate:self];
                
                [self.view insertSubview:self.graphView atIndex:0];
            }
        });
    });
}

#pragma mark GraphViewDelegate

- (void)graphViewDidUpdate:(GraphView *)view{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    self.hud = nil;
}

- (void)graphViewWillUpdate:(GraphView *)view{
    
    if(!self.hud){
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.labelText = NSLocalizedString(@"Loading graph data...", @"");
    }
}


@end
