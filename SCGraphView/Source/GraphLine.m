//
//  GraphLine.m
//  InflowGraph
//
//  Created by Anton Domashnev on 18.02.13.
//  Copyright (c) 2013 Anton Domashnev. All rights reserved.
//

#import "GraphLine.h"
#import "UIBezierPath+Smoothing.h"
#import "UIColor+Graph.h"

#define BEZIER_PATH_GRANULARITY 40
#define BEZIER_PATH_WIDTH 1

@interface GraphLine()

@property (nonatomic, strong) NSArray *pointsArray;
@property (nonatomic, strong) UIColor *lineColor;

@end

@implementation GraphLine

- (id)initWithFrame:(CGRect)frame pointsArray:(NSArray *)thePointsArray {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.pointsArray = thePointsArray;
        self.lineColor = [UIColor graphLightGreenColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    [self.lineColor set];
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path setLineWidth: BEZIER_PATH_WIDTH];
    [path setLineCapStyle:kCGLineCapRound];
    
    int numberOfPoints = [self.pointsArray count];
    
    [path moveToPoint: [self.pointsArray[0] CGPointValue]];
    
    for(int i = 1; i < numberOfPoints; i++){
        
        CGPoint point = [self.pointsArray[i] CGPointValue];
        
        [path addLineToPoint: point];
    }

    UIBezierPath *smoothPath = [path smoothedPathWithGranularity: BEZIER_PATH_GRANULARITY];
    [smoothPath stroke];
}

@end
