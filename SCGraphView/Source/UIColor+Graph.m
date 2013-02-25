//
//  UIColor+Graph.m
//  InflowGraph
//
//  Created by Anton Domashnev on 21.02.13.
//  Copyright (c) 2013 Anton Domashnev. All rights reserved.
//

#import "UIColor+Graph.h"

@implementation UIColor (Graph)

+ (UIColor *)graphHorizontalLineColor{
    
    return [UIColor colorWithRed:163./255. green:69./255. blue:156./255. alpha:1.f];
}

+ (UIColor *)graphHorizontalLineColorAlpha{
    
    return [UIColor colorWithRed:163./255. green:69./255. blue:156./255. alpha:.7f];
}

+ (UIColor *)graphGrayColor{
    
    return [UIColor colorWithRed:44./255. green:9./255. blue:52./255 alpha:.7f];
}

+ (UIColor *)graphBrownColor{
    
    return [UIColor colorWithRed:51./255. green:15./255. blue:57./255 alpha:1.f];
}

+ (UIColor *)graphDarkPurpleColor{
    
    return [UIColor colorWithRed:103./255. green:41./255. blue:106./255. alpha:1.f];
}

+ (UIColor *)graphLightPurpleColor{
    
    return [UIColor colorWithRed:151./255. green:65./255. blue:145./255. alpha:1.f];
}

+ (UIColor *)graphLightGreenColor{
    
    return [UIColor colorWithRed:157./255. green:205./255. blue:7./255. alpha:1.f];
}

+ (UIColor *)graphRedColor{
    
    return [UIColor colorWithRed:224./255. green:0./255. blue:86./255. alpha:1.f];
}

+ (UIColor *)graphPointMinusThreeValueColor{
    
    return [UIColor colorWithRed:22./255. green:34./255. blue:60./255. alpha:1.f];
}

+ (UIColor *)graphPointMinusTwoValueColor{
    
    return [UIColor colorWithRed:38./255. green:60./255. blue:90./255. alpha:1.f];
}

+ (UIColor *)graphPointMinusOneValueColor{
    
    return [UIColor colorWithRed:79./255. green:102./255. blue:121./255. alpha:1.f];
}

+ (UIColor *)graphPointZeroValueColor{
    
    return [UIColor colorWithRed:142./255. green:121./255. blue:115./255. alpha:1.f];
}

+ (UIColor *)graphPointOneValueColor{
    
    return [UIColor colorWithRed:114./255. green:71./255. blue:82./255. alpha:1.f];
}

+ (UIColor *)graphPointTwoValueColor{
    
    return [UIColor colorWithRed:193./255. green:112./255 blue:46./255 alpha:1.f];
}

+ (UIColor *)graphPointThreeValueColor{
    
    return [UIColor colorWithRed:210./255. green:86./255. blue:36./255. alpha:1.f];
}

@end
