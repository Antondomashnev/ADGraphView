//
//  GraphView.m
//  InflowGraph
//
//  Created by Anton Domashnev on 18.02.13.
//  Copyright (c) 2013 Anton Domashnev. All rights reserved.
//

#import "GraphView.h"
#import "GraphLine.h"
#import "GraphPoint.h"
#import "NSDate+Graph.h"
#import "UIFont+Graph.h"
#import "UIColor+Graph.h"
#import <QuartzCore/QuartzCore.h>

#define GRAPH_FRAME CGRectMake(36,0,414,200)
#define VISIBLE_GRAPH_FRAME CGRectMake(36,19,414,144)

#define Y_AXIS_LABEL_IMAGE_VIEW_SIZE CGSizeMake(13, 14)
#define Y_AXIS_LABEL_IMAGE_ORIGIN_X 10.

#define ZOOM_RATE_LABEL_FRAME CGRectMake(200, 220, 200, 20)

#define DAYS_INTERVAL_IMAGE_VIEW_FRAME CGRectMake(44, 220, 410, 16)

@interface GraphView()<UIScrollViewDelegate, GraphScrollableViewDelegate>

@property (nonatomic, unsafe_unretained) NSInteger numberOfDays;
@property (nonatomic, unsafe_unretained) float dayXInterval;

@property (nonatomic, strong) UIScrollView *graphScrollView;
@property (nonatomic, strong) UILabel *zoomRateLabel;

@property (nonatomic, strong) GraphScrollableArea *graphScrollableView;
@property (nonatomic, weak) id<GraphViewDelegate> delegate;

@property (nonatomic, unsafe_unretained) BOOL isGraphViewInialized;

@end

@implementation GraphView

@synthesize graphScrollView;

- (id)initWithFrame:(CGRect)frame objectsArray:(NSArray *)theObjectsArray startDate:(NSDate *)theStartDate endDate:(NSDate *)theEndDate delegate:(id<GraphViewDelegate>)theDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.isGraphViewInialized = NO;
        self.delegate = theDelegate;
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"history_graph_background"]];
        
        self.numberOfDays = [NSDate daysBetweenDateOne:theStartDate dateTwo:theEndDate];
        if(self.numberOfDays < MINIMUM_ZOOM_RATE){
            
            self.numberOfDays = MINIMUM_ZOOM_RATE;
            theEndDate = [theStartDate dateWithDaysAhead: MINIMUM_ZOOM_RATE];
        }
        self.dayXInterval = GRAPH_FRAME.size.width / self.numberOfDays;
        
        [self addYAxisLabels];
        [self addGraphScrollView];
        [self addGraphScrollableViewWithObjectsArray:theObjectsArray startDate:theStartDate endDate:theEndDate];
        [self addZoomRateLabel];
        
        self.graphScrollableView.zoomRate = MINIMUM_ZOOM_RATE;
        [self.graphScrollableView reload];
    }
    return self;
}

#pragma mark ZoomRateLabel

- (void)addZoomRateLabel{
    
    self.zoomRateLabel = [[UILabel alloc] initWithFrame:ZOOM_RATE_LABEL_FRAME];
    
    self.zoomRateLabel.backgroundColor = [UIColor clearColor];
    self.zoomRateLabel.textColor = [UIColor whiteColor];
    self.zoomRateLabel.font = [UIFont defaultGraphBoldFontWithSize: 18.];
    self.zoomRateLabel.alpha = 0.f;
    
    [self addSubview: self.zoomRateLabel];
}

#pragma mark GraphScrollableViewDelegate

- (void)graphScrollableView:(GraphScrollableArea *)view willUpdateFrame:(CGRect)newFrame{
    
    self.graphScrollView.contentSize = newFrame.size;
}

- (void)graphScrollableView:(GraphScrollableArea *)view didChangeZoomRate:(NSInteger)newZoomRate{
    
    self.zoomRateLabel.text = [NSString stringWithFormat:@"%d days", newZoomRate];
}

- (void)graphScrollableViewDidStartUpdateZoomRate:(GraphScrollableArea *)view{
    
    [UIView animateWithDuration:.5f animations:^{
        
        self.zoomRateLabel.alpha = 1.f;
    }];
}

- (void)graphScrollableViewDidEndUpdateZoomRate:(GraphScrollableArea *)view{
    
    [UIView animateWithDuration:.5f animations:^{
        
        self.zoomRateLabel.alpha = 0.f;
    }];
}

- (void)graphScrollableViewDidEndRedraw:(GraphScrollableArea *)view{
    
    if(!self.isGraphViewInialized){
        
        [self scrollToRecentObjects];
        
        self.isGraphViewInialized = YES;
    }
    
    if([self.delegate respondsToSelector:@selector(graphViewDidUpdate:)]){
        
        [self.delegate graphViewDidUpdate: self];
    }
}

- (void)graphScrollableViewDidStartRedraw:(GraphScrollableArea *)view{

    if([self.delegate respondsToSelector:@selector(graphViewWillUpdate:)]){
        
        [self.delegate graphViewWillUpdate: self];
    }
}

#pragma mark Graph ScrollView

- (void)addGraphScrollView{
    
    self.graphScrollView = [[UIScrollView alloc] initWithFrame: GRAPH_FRAME];
    
    self.graphScrollView.delegate = self;
    self.graphScrollView.backgroundColor = [UIColor clearColor];
    [self.graphScrollView setCanCancelContentTouches: YES];
    [self.graphScrollView setUserInteractionEnabled: YES];
    
    [self addSubview: self.graphScrollView];
}

#pragma mark GraphScrollableView

- (void)scrollToRecentObjects{
    
    [self.graphScrollView scrollRectToVisible:[self.graphScrollableView recentObjectsVisibleRect] animated:NO];
}

- (void)addGraphScrollableViewWithObjectsArray:(NSArray *)objectsArray startDate:(NSDate *)startDate endDate:(NSDate *)endDate{
    
    self.graphScrollableView = [[GraphScrollableArea alloc] initWithGraphDataObjectsArray:objectsArray startDate:startDate endDate:endDate delegate:self];
    self.graphScrollableView.backgroundColor = [UIColor clearColor];
    
    [self.graphScrollView addSubview: self.graphScrollableView];
}

#pragma mark Values Labels

- (void)addYAxisLabels{
    
    float xOrigin = Y_AXIS_LABEL_IMAGE_ORIGIN_X;
    
    for(int value = MINIMUM_GRAPH_Y_VALUE; value <= MAXIMUM_GRAPH_Y_VALUE; value++){
        
        float yOrigin = [self pointForValue:@(value) atDayNumber:0].y;
        
        UIImageView *axisImageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin, yOrigin - Y_AXIS_LABEL_IMAGE_VIEW_SIZE.height / 2, Y_AXIS_LABEL_IMAGE_VIEW_SIZE.width, Y_AXIS_LABEL_IMAGE_VIEW_SIZE.height)];
        
        [axisImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"history_graph_%d_label", value]]];
        
        [self addSubview: axisImageView];
    }
}

#pragma mark Value to point convertion

- (CGPoint)pointForValue:(NSNumber *)value atDayNumber:(float)dayNumber{
    
    float x = self.dayXInterval * dayNumber + VISIBLE_GRAPH_FRAME.origin.x;
    float y = VISIBLE_GRAPH_FRAME.size.height + VISIBLE_GRAPH_FRAME.origin.y - ([value floatValue] + MAXIMUM_GRAPH_Y_VALUE) * VALUE_Y_INTERVAL;
    
    return CGPointMake(x, y);
}

#pragma mark Draw Rect

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    //Horizontal dash
    for(int value = -3; value <= 3; value++){
        
        [[UIColor graphHorizontalLineColorAlpha] set];
        
        UIBezierPath *bezier = [[UIBezierPath alloc] init];
        [bezier moveToPoint:[self pointForValue:@(value) atDayNumber:-0.8]];
        [bezier addLineToPoint:[self pointForValue:@(value) atDayNumber:self.numberOfDays]];
        [bezier setLineWidth:1.f];
        [bezier setLineCapStyle:kCGLineCapSquare];
        
        if(value != 0 && value != MINIMUM_GRAPH_Y_VALUE){
            CGFloat dashPattern[2] = {6., 3.};
            [bezier setLineDash:dashPattern count:2 phase:0];
        }
        else{
            
            [[UIColor graphHorizontalLineColor] set];
        }
        
        [bezier stroke];
    }
    
    [[UIColor graphHorizontalLineColor] set];
    
    //Y Axis
    UIBezierPath *bezier = [[UIBezierPath alloc] init];
    [bezier moveToPoint:[self pointForValue:@(MINIMUM_GRAPH_Y_VALUE) atDayNumber:0]];
    [bezier addLineToPoint:[self pointForValue:@(MAXIMUM_GRAPH_Y_VALUE) atDayNumber:0]];
    [bezier setLineWidth:1.f];
    [bezier setLineCapStyle:kCGLineCapSquare];
    
    [bezier stroke];
}


@end
