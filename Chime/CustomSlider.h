//
//  CustomSlider.h
//  ScribbleTouch
//
//  Created by Michael McChesney on 1/16/15.
//  Copyright (c) 2015 Jo Albright. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomSliderDelegate;

@interface CustomSlider : UIView

@property (nonatomic) float alphaSliderValue;
@property (nonatomic) float strokeSliderValue;
@property (nonatomic) NSString * sliderType;

//- (float)sliderValue;

@property (nonatomic,assign) id <CustomSliderDelegate> delegate;

@end

@protocol CustomSliderDelegate <NSObject>
// method to update value
- (void)sliderValue:(float)value forSlider:(NSString *)sliderType;
- (void)saveSliderValue;

@end