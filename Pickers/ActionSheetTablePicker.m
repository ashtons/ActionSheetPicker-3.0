//
//  ActionSheetTablePicker.m
//
//  Created by Sean Ashton on 29/09/2016.
//  Copyright © 2016 Schimera Pty Ltd. All rights reserved.
//


#import "ActionSheetTablePicker.h"

#define IS_IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

@interface ActionSheetTablePicker()<UIGestureRecognizerDelegate>
@property (nonatomic,strong) NSArray *data; //Array
@property (nonatomic,assign) NSInteger selectedIndex;

@end

@implementation ActionSheetTablePicker


+ (instancetype)showPickerWithTitle:(NSString *)title rows:(NSArray *)strings initialSelection:(NSInteger)index doneBlock:(ActionSheetTablePickerDoneBlock)doneBlock cancelBlock:(ActionSheetTablePickerCancelBlock)cancelBlockOrNil origin:(id)origin {
    ActionSheetTablePicker * picker = [[ActionSheetTablePicker alloc] initWithTitle:title rows:strings initialSelection:index doneBlock:doneBlock cancelBlock:cancelBlockOrNil origin:origin];
    picker.titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0]};
    picker.toolbarBackgroundColor = [UIColor blackColor];
    picker.toolbarButtonsColor = [UIColor whiteColor];
    [picker showActionSheetPicker];
    return picker;
}

- (instancetype)initWithTitle:(NSString *)title rows:(NSArray *)data initialSelection:(NSInteger)index target:(id)target successAction:(SEL)successAction cancelAction:(SEL)cancelActionOrNil origin:(id)origin {
    self = [self initWithTarget:target successAction:successAction cancelAction:cancelActionOrNil origin:origin];
    if (self) {
        self.data = data;
        self.selectedIndex = index;
        self.title = title;
        self.popoverDisabled = NO;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title rows:(NSArray *)strings initialSelection:(NSInteger)index doneBlock:(ActionSheetTablePickerDoneBlock)doneBlock cancelBlock:(ActionSheetTablePickerCancelBlock)cancelBlockOrNil origin:(id)origin {
    self = [self initWithTitle:title rows:strings initialSelection:index target:nil successAction:nil cancelAction:nil origin:origin];
    if (self) {
        self.onActionSheetDone = doneBlock;
        self.onActionSheetCancel = cancelBlockOrNil;
    }
    return self;
}

- (CGSize)viewSize {
    if (IS_IPAD) {
        return CGSizeMake(640, 640);
    } else  {
        return [super viewSize];
    }
}


-(void) pressDone {
    NSArray *toolbarItems = self.toolbar.items;
    for(UIBarButtonItem *item in toolbarItems) {
        if (item.style == UIBarButtonItemStyleDone) {
            [[UIApplication sharedApplication] sendAction:item.action
                                                       to:item.target
                                                     from:nil
                                                 forEvent:nil];
            break;
        }
    }
}

- (UIView *)configuredPickerView {
    if (!self.data)
        return nil;
    CGRect pickerFrame = CGRectMake(0, 40, self.viewSize.width, IS_IPAD ? 432 : 216);
    UITableView *stringPicker = [[UITableView alloc] initWithFrame:pickerFrame];
    stringPicker.delegate = self;
    stringPicker.dataSource = self;
    stringPicker.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.pickerView = stringPicker;
    [self performInitialSelectionInPickerView:self.pickerView];
    return stringPicker;
}

- (void)notifyTarget:(id)target didSucceedWithAction:(SEL)successAction origin:(id)origin {
    if (self.onActionSheetDone) {
        _onActionSheetDone(self, _selectedIndex, _selectedIndex == -1 ? nil : self.data[_selectedIndex]);
        return;
    }
    else if (target && [target respondsToSelector:successAction]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:successAction withObject:[NSNumber numberWithInteger:_selectedIndex] withObject:origin];
#pragma clang diagnostic pop
        return;
    }
    NSLog(@"Invalid target/action ( %s / %s ) combination used for ActionSheetPicker and done block is nil.", object_getClassName(target), sel_getName(successAction));
}

- (void)notifyTarget:(id)target didCancelWithAction:(SEL)cancelAction origin:(id)origin {
    if (self.onActionSheetCancel) {
        _onActionSheetCancel(self);
        return;
    }
    else if (target && cancelAction && [target respondsToSelector:cancelAction]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:cancelAction withObject:origin];
#pragma clang diagnostic pop
    }
}

#pragma mark - UIPickerViewDelegate / DataSource


- (NSInteger)tableView:(__unused UITableView *)tableView numberOfRowsInSection:(__unused NSInteger)section {
    return (NSInteger)self.data.count;
}


- (UITableViewCell *)tableView:(__unused UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    UITableViewCell *cell = nil;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.tag = indexPath.row;
        UITapGestureRecognizer * singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleSelection:)];
        singleTapGestureRecognizer.numberOfTapsRequired = 1;
        singleTapGestureRecognizer.cancelsTouchesInView = YES;
        singleTapGestureRecognizer.delegate = self;
        cell.textLabel.userInteractionEnabled = YES;
        [cell addGestureRecognizer:singleTapGestureRecognizer];
    }
    if (_selectedIndex == indexPath.row) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
         [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    id obj = (self.data)[(NSUInteger) indexPath.row];
    cell.textLabel.text = [obj description];   
    cell.userInteractionEnabled = YES;
    cell.contentView.userInteractionEnabled = YES;
    return cell;
}
- (void)tableView:(__unused UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSUInteger row = (NSUInteger)[indexPath row];
    int a = row % 2;
    if (a == 0) {
        cell.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    } else{
        cell.backgroundColor = [UIColor whiteColor];
    }
    
}
-(BOOL)gestureRecognizer:(__unused UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(__unused UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
- (BOOL)gestureRecognizer:(__unused UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(__unused UITouch *)touch {
    return YES;
}
- (void)toggleSelection:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        NSNumber *row = [NSNumber numberWithInteger:recognizer.view.tag];
        if (_selectedIndex == [row integerValue]) {
            _selectedIndex = -1;
        } else {
            _selectedIndex = [row integerValue];
        }
        if (_selectedIndex == -1) {
            [(UITableViewCell *)(recognizer.view) setAccessoryType:UITableViewCellAccessoryNone];
        } else {
            [(UITableViewCell *)(recognizer.view) setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        UITableView *tableView =  (UITableView *)self.pickerView;
        [tableView reloadRowsAtIndexPaths:[tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self pressDone];
       
    }
}



- (void)performInitialSelectionInPickerView:(__unused UIView *)pickerView {    
    
}


@end

