//
//  HorizontalTableView.h
//  Scroller
//
//  Created by Martin Volerich on 5/22/10.
//  Copyright 2010 Martin Volerich - Bill Bear Technologies. All rights reserved.
//

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the Software without restriction, including without
// limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so, subject to the following
// conditions:
// 
// The above copyright notice and this permission notice shall be included in all copies or substantial
// portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
// LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
// AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
// OR OTHER DEALINGS IN THE SOFTWARE.

#import <UIKit/UIKit.h>

@class HorizontalTableView;

@protocol HorizontalTableViewDelegate

- (NSInteger)numberOfColumnsForTableView:(HorizontalTableView *)tableView;
- (UIView *)tableView:(HorizontalTableView *)tableView viewForIndex:(NSInteger)index;
- (CGFloat)columnWidthForTableView:(HorizontalTableView *)tableView;
- (void)didSelectColumn:(NSInteger)column;

@end

@interface HorizontalTableView : UIView
{
	NSMutableArray *_pageViews;
	UIScrollView *_scrollView;
	NSUInteger _currentPageIndex;
	NSUInteger _currentPhysicalPageIndex;
    
    NSInteger _visibleColumnCount;
    NSNumber *_columnWidth;
    
    NSObject<HorizontalTableViewDelegate>* _delegate;
    
    NSMutableArray *_columnPool;
    
    HorizontalTableView* _sectionView;
    NSMutableArray* _sectionOffsets;
    NSMutableArray* _sectionIndices;
    
    NSInteger  _currentSection;
    CGFloat _sectionWidth;
}

@property (nonatomic, strong) IBOutlet NSObject<HorizontalTableViewDelegate>* delegate;
@property (nonatomic, strong) HorizontalTableView* sectionView;
@property (nonatomic, strong) NSArray* sectionIndices;

- (void)refreshData;
- (UIView *)dequeueColumnView;

- (void) scrollToOffset:(CGFloat)offset;

@end
