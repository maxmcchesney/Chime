//
//  CustomSlider.m
//  ScribbleTouch
//
//  Created by Michael McChesney on 1/16/15.
//  Copyright (c) 2015 Michael McChesney All rights reserved.
//

#import "CustomSlider.h"
IB_DESIGNABLE

@implementation CustomSlider
{
    CGFloat touchX;

}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code

    // VARIABLES
    CGFloat height = rect.size.height;
    CGFloat width = rect.size.width;
//    touchX = width;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Slider line
    CGContextMoveToPoint(ctx, 0, height/2);
    CGContextAddLineToPoint(ctx, width, height/2);
    CGContextSetLineWidth(ctx, 1);
    CGContextStrokePath(ctx);
    
    // Circle button
    CGFloat circleDiameter = 30;
    CGFloat x;
    
    if ([self.sliderType isEqualToString:@"alpha"]) {

        
        // if slider alpha: slider button starts at the right
        if (touchX == 0) {
            x = width - circleDiameter;
        } else {
            x = touchX - circleDiameter / 2;
            if (x > width - circleDiameter) x = width - circleDiameter;
            if ( x < 0) x = 0;
        }
    } else {
            x = touchX - circleDiameter / 2;
            if (x > width - circleDiameter) x = width - circleDiameter;
            if ( x < 0) x = 0;
    }
    
    CGRect button = CGRectMake(x, 0, circleDiameter, circleDiameter);
    
    CGContextFillEllipseInRect(ctx, button);
    
//    NSLog(@"%f",[self sliderValue]);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch * touch = touches.allObjects.firstObject;
    
    CGPoint location = [touch locationInView:self];
    
    touchX = location.x;
    
    [self setNeedsDisplay];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch * touch = touches.allObjects.firstObject;
    
    CGPoint location = [touch locationInView:self];
    
    touchX = location.x;
    
    self.alphaSliderValue = [self sliderValue];
    
    [self setNeedsDisplay];
    
}


- (float)sliderValue {
    
    CGFloat width = self.frame.size.width;
    CGFloat circleDiameter = 30;
    CGFloat x = touchX - circleDiameter / 2;
    if (x > width - circleDiameter) x = width - circleDiameter;
    if ( x < 0) x = 0;

    // slider starts at 0: so the value is x value / width of the slider. And since x is the touchX - circleDiameter / 2. The value is (x / width) + circleDiameter/2
    [self.delegate sliderValue:x / (width - circleDiameter) forSlider:self.sliderType];
    
//    NSLog(@"slider value: %f", x / (width - circleDiameter));
    return x / (width - circleDiameter);
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // save rating here?
    
    [self.delegate saveSliderValue];
    
}


@end
