//
//  GraphScrollableArea.m
//  InflowGraph
//
//  Created by Anton Domashnev on 20.02.13.
//  Copyright (c) 2013 Anton Domashnev. All rights reserved.
//

#import "GraphScrollableArea.h"
#import "GraphLine.h"
#import "NSDate+Graph.h"
#import "UIColor+Graph.h"
#import "UIFont+Graph.h"

#define VISIBLE_FRAME CGRectMake(0, 0, 410, 200)
#define GRAPH_SCROLLABLE_VIEW_FRAME_WIDTH_DELTA 28

#define Y_OFFSET_FOR_GRAPH_POINTS 38

#define GRAPH_POINT_SIZE CGSizeMake(18, 18)

#define MAXIMUM_ZOOM_SCALE_FOR_DRAWNING_OBJECT_POINT 20

#define INTERVAL_BETWEEN_DRAWNING_DATE_POINT 41

#define MAXIMUM_FRAME_WIDTH 3000

#define X_AXIS_DATE_POINT_RADIUS 2
#define X_AXIS_DATE_POINT_BORDER_OVAL_RADIUS 3

#define DAY_STRING_FRAME CGRectMake(0, 167, 14, 14)
#define MONTH_STRING_FRAME CGRectMake(0, 182, 15, 12)
#define DAY_STRING_HORIZINTAL_LINE_Y_COORDINATE 182

@interface GraphScrollableArea()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray *objectsArray;

@property (nonatomic, strong) GraphLine *objectsLine;

@property (nonatomic, unsafe_unretained) NSInteger startUNIXDate;
@property (nonatomic, unsafe_unretained) NSInteger endUNIXDate;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic, unsafe_unretained) NSInteger numberOfDays;
@property (nonatomic, unsafe_unretained) NSInteger newZoomRate;
@property (nonatomic, unsafe_unretained) float dayIntervalWidth;
@property (nonatomic, unsafe_unretained) float maximumZoomRate;
@property (nonatomic, unsafe_unretained) float minimumZoomRate;

@property (nonatomic, weak) id<GraphScrollableViewDelegate> delegate;

@end

@implementation GraphScrollableArea

@synthesize zoomRate;
@synthesize newZoomRate;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithGraphDataObjectsArray:(NSArray *)objectsArray startDate:(NSDate *)startDate endDate:(NSDate *)endDate delegate:(id<GraphScrollableViewDelegate>)theDelegate{
    
    if(self = [super initWithFrame: VISIBLE_FRAME]){
        
        self.backgroundColor = [UIColor clearColor];
        
        self.delegate = theDelegate;
        self.startUNIXDate = [startDate timeIntervalSince1970];
        self.endUNIXDate = [endDate timeIntervalSince1970];
        self.objectsArray = objectsArray;
        
        self.startDate = startDate;
        self.endDate = endDate;
        
        self.numberOfDays = [NSDate daysBetweenDateOne:startDate dateTwo:endDate];
        self.maximumZoomRate = self.numberOfDays;
        self.minimumZoomRate = 10.f;
        
        self.userInteractionEnabled = YES;
        
        UIPinchGestureRecognizer *pinchRecogniser = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(userDidUsePinchGesture:)];
        
        [self addGestureRecognizer:pinchRecogniser];
    }
    
    return self;

}

- (void)dealloc{
    
    self.delegate = nil;
}

#pragma mark Check Zoom Rate

- (BOOL)isZoomRateValid:(NSInteger)zoom{
    
    return (zoom >= self.minimumZoomRate && zoom <= self.maximumZoomRate);
}

- (void)correctNewZoomScale{
    
    if(self.newZoomRate > self.maximumZoomRate){
        
        self.newZoomRate = self.maximumZoomRate;
    }
    else if(self.newZoomRate < self.minimumZoomRate){
        
        self.newZoomRate = self.minimumZoomRate;
    }
}

#pragma mark PinchGesture

- (void)userDidUsePinchGesture:(UIPinchGestureRecognizer *)recogniser{
    
    self.newZoomRate = self.zoomRate / [recogniser scale];
    
    [self correctNewZoomScale];
    
    if([self.delegate respondsToSelector:@selector(graphScrollableView:didChangeZoomRate:)]){
        
        [self.delegate graphScrollableView:self didChangeZoomRate:self.newZoomRate];
    }
    
    switch (recogniser.state) {
        case UIGestureRecognizerStateEnded:{
            
            if([self.delegate respondsToSelector:@selector(graphScrollableViewDidEndUpdateZoomRate:)]){
                
                [self.delegate graphScrollableViewDidEndUpdateZoomRate: self];
            }
            
            if(self.zoomRate != self.newZoomRate){
                
                self.zoomRate = self.newZoomRate;
                
                [self reload];
            }
            break;
        }
        case UIGestureRecognizerStateBegan:{
            
            if([self.delegate respondsToSelector:@selector(graphScrollableViewDidStartUpdateZoomRate:)]){
                
                [self.delegate graphScrollableViewDidStartUpdateZoomRate: self];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark Recent

- (CGRect)recentObjectsVisibleRect{
    
    CGRect rect = VISIBLE_FRAME;
    rect.origin.x = self.frame.size.width - VISIBLE_FRAME.size.width - GRAPH_SCROLLABLE_VIEW_FRAME_WIDTH_DELTA;
    
    return rect;
}

#pragma mark Recalculate Dates

- (void)recalculateStartDate{
    
    self.startUNIXDate = self.endUNIXDate - [self numberOfDaysInWidth: self.frame.size.width - GRAPH_SCROLLABLE_VIEW_FRAME_WIDTH_DELTA] * NUMBER_OF_SECONDS_IN_DAY;
    
    self.startDate = [NSDate dateWithTimeIntervalSince1970: self.startUNIXDate];
}

#pragma mark Zoom Rate

- (void)setZoomRate:(NSInteger)_zoomRate{
    
    if([self isZoomRateValid: _zoomRate]){
        
        self->zoomRate = _zoomRate;
    }
}

#pragma mark Reload

- (void)reload{
    
    if([self.delegate respondsToSelector:@selector(graphScrollableViewDidStartRedraw:)]){
        
        [self.delegate graphScrollableViewDidStartRedraw: self];
    }
    
    CGRect newFrame = [self frameForCurrentZoomRate];
    
    [self.delegate graphScrollableView:self willUpdateFrame:newFrame];
    
    self.frame = newFrame;
    
    [self recalculateStartDate];
    
    [self removeOldSubviews];
    
    [self setNeedsDisplay];
    
    [self reloadWithStartDay:0 completionCallback:^{
       
        if([self.delegate respondsToSelector:@selector(graphScrollableViewDidEndRedraw:)]){
            
            [self.delegate graphScrollableViewDidEndRedraw: self];
        }
    }];
}

#pragma mark Remove Old Subviews

- (void)removeOldSubviews{
    
    [self.objectsLine removeFromSuperview];
    self.objectsLine = nil;
    
    for(UIView *view in self.subviews){
        
        if([view isKindOfClass:[GraphPoint class]]){
            
            [view removeFromSuperview];
        }
    }
}

#pragma mark Value to point convertion

- (CGPoint)pointForValue:(NSNumber *)value atDayNumber:(float)dayNumber{
    
    float x = self.dayIntervalWidth * dayNumber + GRAPH_SCROLLABLE_VIEW_FRAME_WIDTH_DELTA / 2;
    float y = VISIBLE_FRAME.size.height - Y_OFFSET_FOR_GRAPH_POINTS - ([value floatValue] + MAXIMUM_GRAPH_Y_VALUE) * VALUE_Y_INTERVAL;
    
    return CGPointMake(x, y);
}

- (CGFloat)xCoordinateForDayNumber:(float)dayNumber{
    
    return self.dayIntervalWidth * dayNumber + GRAPH_SCROLLABLE_VIEW_FRAME_WIDTH_DELTA / 2;
}

#pragma mark Lines

- (void)drawLineWithPointsArray:(NSArray *)pointsArray{
    
    self.objectsLine = [[GraphLine alloc] initWithFrame:self.bounds pointsArray:pointsArray minY:[self pointForValue:@(3) atDayNumber:0].y maxY:[self pointForValue:@(-3) atDayNumber:0].y];
    [self addSubview: self.objectsLine];
}

#pragma mark Points

- (void)drawPointAtPosition:(CGPoint)position withObject:(GraphDataObject *)object{
    
    GraphPoint *point = nil;
    
    if([self.delegate conformsToProtocol:@protocol(GraphPointDelegate)]){
        
        point = [[GraphPoint alloc] initWithFrame:CGRectMake(position.x - GRAPH_POINT_SIZE.width / 2, position.y - GRAPH_POINT_SIZE.height / 2, GRAPH_POINT_SIZE.width, GRAPH_POINT_SIZE.height) associatedObject:object delegate:(id<GraphPointDelegate>)self.delegate];
    }
    else{
        
        point = [[GraphPoint alloc] initWithFrame:CGRectMake(position.x - GRAPH_POINT_SIZE.width / 2, position.y - GRAPH_POINT_SIZE.height / 2, GRAPH_POINT_SIZE.width, GRAPH_POINT_SIZE.height) associatedObject:object delegate: nil];
    }
    
    
    [self addSubview: point];
}

#pragma mark Average

- (NSNumber *)averageObjectValueForKey:(NSString *)key inArray:(NSArray *)array{
    
    __block float sum = 0.;
    int count = [array count];
    
    if(count != 0){
        
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            sum += [[obj valueForKey: key] floatValue];
        }];
        
        float average = (float)sum / (float)count;
        
        return [NSNumber numberWithFloat: average];
    }
    
    return @0;
}

#pragma mark Calculate Graph Data

- (NSArray *)objectsForDayNumber:(NSInteger)dayNumber{
    
    NSArray *dayObjectsArray = [self.objectsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.time >= %@ && SELF.time < %@", [NSDate dateWithTimeIntervalSince1970:(self.startUNIXDate + NUMBER_OF_SECONDS_IN_DAY*dayNumber)], [NSDate dateWithTimeIntervalSince1970:(self.startUNIXDate + NUMBER_OF_SECONDS_IN_DAY * (dayNumber + 1))]]];
    
    return dayObjectsArray;
}

#pragma mark Reload

- (void)reloadWithStartDay:(NSInteger)startDay completionCallback:(void(^)(void))callback{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSInteger numberOfVisibleDays = [self numberOfDaysInWidth: self.frame.size.width - GRAPH_SCROLLABLE_VIEW_FRAME_WIDTH_DELTA];
        
        NSMutableArray *objectsLinePoints = [NSMutableArray array];
        NSMutableDictionary *dailyObjects = [NSMutableDictionary dictionary];
        
        for(int dayNumber = startDay; dayNumber <= numberOfVisibleDays; dayNumber++){
            
            NSArray *dailyObjectsArray = [self objectsForDayNumber: dayNumber];
            [dailyObjects setObject: dailyObjectsArray forKey: [NSString stringWithFormat:@"%d", dayNumber]];
            
            if([dailyObjectsArray count] > 0){
                
                [objectsLinePoints addObject: [NSValue valueWithCGPoint: [self pointForValue:[self averageObjectValueForKey:@"value" inArray:dailyObjectsArray] atDayNumber:dayNumber]]];
            }

        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if([objectsLinePoints count] > 0){
                
                [self drawLineWithPointsArray:objectsLinePoints];
            }
            
            if(self.zoomRate <= MAXIMUM_ZOOM_SCALE_FOR_DRAWNING_OBJECT_POINT){
            
                for(NSString *dayNumber in [dailyObjects allKeys]){
                    
                    for(GraphDataObject *object in dailyObjects[dayNumber]){
                        
                        [self drawPointAtPosition:[self pointForValue:object.value atDayNumber:[dayNumber integerValue]] withObject:object];
                    }
                }
            }
            
            callback();
        });
    });
}

#pragma mark Size

- (CGRect)frameForCurrentZoomRate{
    
    CGSize newSize = [self newSizeForCurrentZoomRate];
    CGRect frame = VISIBLE_FRAME;
    frame.size.width = (newSize.width <= MAXIMUM_FRAME_WIDTH) ? newSize.width : MAXIMUM_FRAME_WIDTH;
    
    return frame;
}

- (CGSize)newSizeForCurrentZoomRate{
    
    self.dayIntervalWidth = VISIBLE_FRAME.size.width / (float)self.zoomRate;
    float newGraphWidth = self.dayIntervalWidth * self.numberOfDays + GRAPH_SCROLLABLE_VIEW_FRAME_WIDTH_DELTA;
    
    return CGSizeMake(newGraphWidth, VISIBLE_FRAME.size.height);
}

#pragma mark Number of days in width

- (NSInteger)numberOfDaysInWidth:(CGFloat)width{
    
    int numberOfDays = (int)(width / self.dayIntervalWidth + 0.5);
    
    return numberOfDays;
}

- (NSInteger)daysIntervalBetweenGraphMark{
    
    return (int)(INTERVAL_BETWEEN_DRAWNING_DATE_POINT / self.dayIntervalWidth + 0.5);
}

#pragma mark Draw

- (void)drawDateForDayNumber:(NSInteger)dayNumber{
    
    //Day number
    [[UIColor whiteColor] set];
    
    NSDate *localDateForDayNumber = [[self.startDate dateWithDaysAhead: dayNumber] localDate];    
    NSInteger day = [localDateForDayNumber dayNumber];
    NSString *dayString = [NSString stringWithFormat: @"%@%d", (day < 10) ? @"0" : @"", day];
    
    float x = [self xCoordinateForDayNumber: dayNumber];
    CGRect dayStringFrame = DAY_STRING_FRAME;
    dayStringFrame.origin.x = x - DAY_STRING_FRAME.size.width / 2;
    
    [dayString drawInRect:dayStringFrame withFont:[UIFont defaultGraphBoldFontWithSize: 12.]];
    
    [[UIColor graphDarkPurpleColor] set];
    
    //Divider
    UIBezierPath *horizontalLine = [[UIBezierPath alloc] init];
    
    [horizontalLine setLineCapStyle:kCGLineCapSquare];
    [horizontalLine setLineWidth: 1.f];
    
    [horizontalLine moveToPoint: CGPointMake(dayStringFrame.origin.x - MAXIMUM_GRAPH_Y_VALUE, DAY_STRING_HORIZINTAL_LINE_Y_COORDINATE)];
    [horizontalLine addLineToPoint: CGPointMake(dayStringFrame.origin.x + dayStringFrame.size.width + MAXIMUM_GRAPH_Y_VALUE, DAY_STRING_HORIZINTAL_LINE_Y_COORDINATE)];
    
    [horizontalLine stroke];
    
    [[UIColor graphLightPurpleColor] set];
    
    //Month
    NSString *month = [[localDateForDayNumber monthShortStringDescription] lowercaseString];
    CGRect monthStringFrame = MONTH_STRING_FRAME;
    monthStringFrame.origin.x = x - MONTH_STRING_FRAME.size.width / 2;
    
    [month drawAtPoint:CGPointMake(x - MONTH_STRING_FRAME.size.width / 2, MONTH_STRING_FRAME.origin.y) withFont:[UIFont defaultGraphBoldFontWithSize: 10.]];
    
}

- (void)drawRect:(CGRect)rect
{
    //Vertical dash
    
    NSInteger daysIntervalBetweenGraphMark = [self daysIntervalBetweenGraphMark];
    NSInteger numberOfVisibleDays = [self numberOfDaysInWidth: self.frame.size.width - GRAPH_SCROLLABLE_VIEW_FRAME_WIDTH_DELTA];
    
    for(int day = 0; day <= numberOfVisibleDays; day+=daysIntervalBetweenGraphMark){
        
        [[UIColor graphGrayColor] set];
        
        UIBezierPath *bezier = [[UIBezierPath alloc] init];
        
        CGPoint startPoint = [self pointForValue:@(MINIMUM_GRAPH_Y_VALUE) atDayNumber:day];
        [bezier moveToPoint:startPoint];
        
        CGPoint endPoint = [self pointForValue:@(MAXIMUM_GRAPH_Y_VALUE) atDayNumber:day];
        [bezier addLineToPoint:endPoint];
        
        [bezier setLineWidth:1.f];
        [bezier setLineCapStyle:kCGLineCapSquare];
         
        CGFloat dashPattern[2] = {2., 2.};
        [bezier setLineDash:dashPattern count:2 phase:0];
         
        [bezier stroke];
        
        [[UIColor graphBrownColor] set];
        UIBezierPath *datePoint = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(startPoint.x - X_AXIS_DATE_POINT_RADIUS, startPoint.y - X_AXIS_DATE_POINT_RADIUS, X_AXIS_DATE_POINT_RADIUS * 2, X_AXIS_DATE_POINT_RADIUS * 2)];
        [datePoint fill];
        
        [[UIColor graphLightPurpleColor] set];
        UIBezierPath *dateBorder = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(startPoint.x - X_AXIS_DATE_POINT_BORDER_OVAL_RADIUS, startPoint.y - X_AXIS_DATE_POINT_BORDER_OVAL_RADIUS, X_AXIS_DATE_POINT_BORDER_OVAL_RADIUS * 2, X_AXIS_DATE_POINT_BORDER_OVAL_RADIUS * 2)];
        [dateBorder stroke];
        
        //Draw dates
        [self drawDateForDayNumber: day];
    }
}

@end
