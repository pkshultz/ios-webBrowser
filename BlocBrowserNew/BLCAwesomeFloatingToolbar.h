//
//  BLCAwsomeFloatingToolbar.h
//  BlocBrowser
//
//  Created by Peter Shultz on 11/19/14.
//  Copyright (c) 2014 Peter Shultz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCAwsomeFloatingToolbar;

@protocol BLCAwesomeFloatingToolbarDelegate <NSObject>

@optional

- (void) floatingToolbar: (BLCAwsomeFloatingToolbar* )toolbar didSelectButtonWithTitle:(NSString* )title;
- (void) floatingToolbar:(BLCAwsomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset;
- (void) floatingToolbar:(BLCAwsomeFloatingToolbar *)toolbar didPinchWithOffset:(CGFloat)offset;
- (void) floatingToolbar:(BLCAwsomeFloatingToolbar *)toolbar didLongPressWithOffset:(CGPoint)offset;

@end

@interface BLCAwsomeFloatingToolbar : UIView

- (instancetype) initWithFourTitles:(NSArray*)titles;

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString*)title;

@property (nonatomic, weak) id <BLCAwesomeFloatingToolbarDelegate> delegate;

@end
