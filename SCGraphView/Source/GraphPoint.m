//
//  GraphPoint.m
//  InflowGraph
//
//  Created by Anton Domashnev on 18.02.13.
//  Copyright (c) 2013 Anton Domashnev. All rights reserved.
//

#import "GraphPoint.h"
#import "UIColor+Graph.h"

#define VISIBLE_CIRCLE_FRAME CGRectMake(6, 6, 6, 6)

@interface GraphPoint()

@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, weak) id<GraphPointDelegate> delegate;
@property (nonatomic, strong) GraphDataObject *associatedObject;

@end

@implementation GraphPoint

- (id)initWithFrame:(CGRect)frame associatedObject:(GraphDataObject *)theAssociatedObject delegate:(id<GraphPointDelegate>)theDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
        self.delegate = theDelegate;
        self.associatedObject = theAssociatedObject;
        self.fillColor = [self fillColorForValue: theAssociatedObject.value];
    }
    return self;
}

#pragma mark Fill Color

- (UIColor *)fillColorForValue:(NSNumber *)value{
    
    switch ([value integerValue]) {
        case -3: return [UIColor graphPointMinusThreeValueColor]; break;
        case -2: return [UIColor graphPointMinusTwoValueColor]; break;
        case -1: return [UIColor graphPointMinusOneValueColor]; break;
        case 0: return [UIColor graphPointZeroValueColor]; break;
        case 1: return [UIColor graphPointOneValueColor]; break;
        case 2: return [UIColor graphPointTwoValueColor]; break;
        case 3: return [UIColor graphPointThreeValueColor]; break;
        default: break;
    }
    
    return [UIColor clearColor];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if([self.delegate respondsToSelector:@selector(graphPointClicked:withObject:)]){
        
        [self.delegate graphPointClicked:self withObject:self.associatedObject];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self.fillColor set];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect: VISIBLE_CIRCLE_FRAME];
    
    [path fill];
}


@end
