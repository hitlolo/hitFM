//
//  LXMLyricsLabel.m
//  LXMLyricsLabel
//
//  Created by luxiaoming on 15/9/8.
//  Copyright (c) 2015年 luxiaoming. All rights reserved.
//

#import "LXMLyricsLabel.h"

@interface LXMLyricsLabel ()



@end

@implementation LXMLyricsLabel

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {

    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
      
    }
    return self;
}

- (void)setupDefault {
    
//    self.maskTextColor = [UIColor colorWithRed:207/255.0 green:169/255.0 blue:114/255.0 alpha:1.0];
    self.maskTextColor = [UIColor orangeColor];
    self.maskBackgroundColor = [UIColor clearColor];
    
    self.maskLabel.textColor = self.maskTextColor;
    self.maskLabel.backgroundColor = self.maskBackgroundColor;
    
    CALayer *maskLayer = [CALayer layer];
    maskLayer.anchorPoint = CGPointMake(0, 0.5);//注意，按默认的anchorPoint，width动画是同时像左右扩展的
    maskLayer.position = CGPointMake(0, CGRectGetHeight(self.bounds) / 2);
    maskLayer.bounds = CGRectMake(0, 0, 0, CGRectGetHeight(self.bounds));
    maskLayer.backgroundColor = [UIColor whiteColor].CGColor;

    self.maskLabel.layer.mask = maskLayer;
    self.maskLayer = maskLayer;
    
    
}

#pragma mark - publicMethod


- (void)startLyricsAnimationWithTimeArray:(NSArray *)timeArray andLocationArray:(NSArray *)locationArray {
    
    [self bringSubviewToFront:self.maskLabel];
    CGFloat totalDuration = [timeArray.lastObject floatValue];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"bounds.size.width"];
    NSMutableArray *keyTimeArray = [NSMutableArray array];
    NSMutableArray *widthArray = [NSMutableArray array];
    for (int i = 0 ; i < timeArray.count; i++) {
        CGFloat tempTime = [timeArray[i] floatValue] / totalDuration;
        [keyTimeArray addObject:@(tempTime)];
        CGFloat tempWidth = [locationArray[i] floatValue] * CGRectGetWidth(self.bounds);
        [widthArray addObject:@(tempWidth)];
    }
   
    animation.values = widthArray;
    animation.keyTimes = keyTimeArray;
    animation.duration = totalDuration;
    animation.calculationMode = kCAAnimationLinear;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [self.maskLayer addAnimation:animation forKey:@"kLyrcisAnimation"];
}

- (void)stopAnimation {
    [self.maskLayer removeAllAnimations];
}

#pragma mark - setter 

- (void)setText:(NSString *)text {
    [super setText:text];
    self.maskLabel.text = text;
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    self.maskLabel.font = font;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    [self.maskLabel setTextAlignment:textAlignment];
}




#pragma mark - property

- (UILabel *)maskLabel {
    if (!_maskLabel) {
        _maskLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [self addSubview:self.maskLabel];
        [self setupDefault];
        NSLayoutConstraint *constraintX = [NSLayoutConstraint constraintWithItem:self.maskLabel attribute: NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.maskLabel.superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint *constraintY = [NSLayoutConstraint constraintWithItem:self.maskLabel attribute: NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.maskLabel.superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        [self addConstraints:@[constraintX,constraintY]];
    }
    return _maskLabel;
}

@end
