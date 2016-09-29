//
//  ActionSheetTablePicker.h
//
//  Created by Sean Ashton on 29/09/2016.
//  Copyright © 2016 Schimera Pty Ltd. All rights reserved.
//
#import "AbstractActionSheetPicker.h"

@class ActionSheetTablePicker;

typedef void(^ActionSheetTablePickerDoneBlock)(ActionSheetTablePicker *picker, NSInteger selectedIndex, id selectedValue);
typedef void(^ActionSheetTablePickerCancelBlock)(ActionSheetTablePicker *picker);

@interface ActionSheetTablePicker : AbstractActionSheetPicker <UITableViewDataSource, UITableViewDelegate>

+ (instancetype)showPickerWithTitle:(NSString *)title rows:(NSArray *)strings initialSelection:(NSInteger)index doneBlock:(ActionSheetTablePickerDoneBlock)doneBlock cancelBlock:(ActionSheetTablePickerCancelBlock)cancelBlock origin:(id)origin;
- (instancetype)initWithTitle:(NSString *)title rows:(NSArray *)data initialSelection:(NSInteger)index target:(id)target successAction:(SEL)successAction cancelAction:(SEL)cancelActionOrNil origin:(id)origin;
- (instancetype)initWithTitle:(NSString *)title rows:(NSArray *)strings initialSelection:(NSInteger)index doneBlock:(ActionSheetTablePickerDoneBlock)doneBlock cancelBlock:(ActionSheetTablePickerCancelBlock)cancelBlockOrNil origin:(id)origin;


@property (nonatomic, copy) ActionSheetTablePickerDoneBlock onActionSheetDone;
@property (nonatomic, copy) ActionSheetTablePickerCancelBlock onActionSheetCancel;
@end
