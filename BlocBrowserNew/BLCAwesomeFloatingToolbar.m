//
//  BLCAwsomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Peter Shultz on 11/19/14.
//  Copyright (c) 2014 Peter Shultz. All rights reserved.
//

#import "BLCAwesomeFloatingToolbar.h"

@interface BLCAwsomeFloatingToolbar ()

@property (nonatomic, strong) NSArray* currentTitles;
@property (nonatomic, strong) NSArray* colors;
@property (nonatomic, strong) NSArray* labels;
@property (nonatomic, weak) UILabel* currentLabel;
@property (nonatomic, strong) UITapGestureRecognizer* tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer* panGesture;

//Added for the inappropriate gestures assignment

@property (nonatomic, strong) UIPinchGestureRecognizer* pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer* longPressGesture;

@end

@implementation BLCAwsomeFloatingToolbar

- (instancetype) initWithFourTitles:(NSArray *)titles
{
    self = [super init];
    
    if (self)
    {
        //Save titles and set four colors
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        NSMutableArray* labelsArray = [[NSMutableArray alloc] init];
        
        //Make four labels
        for (NSString* currentTitle in self.currentTitles)
        {
            UILabel* label = [[UILabel alloc] init];
            label.userInteractionEnabled = NO;
            label.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; //O through 3
            NSString* titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor* colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
            
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:12];
            label.text = titleForThisLabel;
            label.backgroundColor = colorForThisLabel;
            label.textColor = [UIColor whiteColor];
            
            [labelsArray addObject:label];
        }
        
        self.labels = labelsArray;
        
        for (UILabel* thisLabel in self.labels)
        {
            [self addSubview:thisLabel];
        }
        
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        [self addGestureRecognizer:self.tapGesture];
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        [self addGestureRecognizer:self.longPressGesture];
    }

    return self;
}

- (void) layoutSubviews
{
    //Set the frames of the four labels
    
    for (UILabel* thisLabel in self.labels)
    {
        NSUInteger currentLabelIndex = [self.labels indexOfObject:thisLabel];
        
        CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat labelWidth  = CGRectGetWidth(self.bounds) / 2;
        CGFloat labelX = 0;
        CGFloat labelY = 0;
        
        //Adjust labelX and labelY for each label
        if (currentLabelIndex < 2)
        {
            labelY = 0;
        }
        
        else
        {
            labelY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentLabelIndex % 2 == 0)
        {
            labelX = 0;
        }
        else
        {
            labelX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
        
        
        
    }
}

#pragma mark - Touch Handling

- (void) tapFired:(UITapGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint location = [recognizer locationInView:self];
        
        UIView* tappedView = [self hitTest:location withEvent:nil];
        
        if ([self.labels containsObject:tappedView])
        {
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)])
            {
                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel*)tappedView).text];
            }
            
        }
    }
}

- (void) pinchFired:(UIPinchGestureRecognizer*)recognizer
{
    //Ideas:
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        
        CGFloat scale = [recognizer scale];
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didPinchWithOffset:)])
        {
            [self.delegate floatingToolbar:self didPinchWithOffset:scale];
        }
        
    }
    
}

- (void) longPressFired:(UILongPressGestureRecognizer*)recognizer
{
    //Ideas:
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        UIColor* firstLabelColor = ((UILabel*)self.labels[0]).backgroundColor;
        
        for (NSInteger i = 0; i < self.colors.count; i++)
        {
            UILabel* currentLabel = self.labels[i];
            
            currentLabel.backgroundColor = ((UILabel*)self.labels[(i + 1) % self.colors.count]).backgroundColor;
            
            if (i == (self.colors.count - 1))
            {
                ((UILabel*)self.labels[i]).backgroundColor = firstLabelColor;
            }
        }
        
    }
}


- (void) panFired:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)])
        {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title
{
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound)
    {
        UILabel* label = [self.labels objectAtIndex:index];
        label.userInteractionEnabled = enabled;
        label.alpha = enabled ? 1.0 : 0.25;
    }
}

@end
