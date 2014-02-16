//
//  HorizontalTableView.m
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

#import "HorizontalTableView.h"

#define kColumnPoolSize 3

@interface HorizontalTableView() <UIScrollViewDelegate>

@property (nonatomic, retain) NSMutableArray *pageViews;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, readonly) NSUInteger currentPageIndex;
@property (nonatomic) NSUInteger physicalPageIndex;
@property (nonatomic, retain) NSMutableArray *columnPool;
@property (nonatomic, assign, readonly) CGFloat sectionWidth;
- (void)prepareView;
- (void)layoutPages;
- (void)currentPageIndexDidChange;
- (NSUInteger)numberOfPages;
- (void)layoutPhysicalPage:(NSUInteger)pageIndex;
- (UIView *)viewForPhysicalPage:(NSUInteger)pageIndex;
- (void)removeColumn:(NSInteger)index;

@end


@implementation HorizontalTableView

@synthesize pageViews=_pageViews;
@synthesize scrollView=_scrollView;
@synthesize currentPageIndex=_currentPageIndex;
@synthesize delegate=_delegate;
@synthesize columnPool=_columnPool;
@synthesize sectionView = _sectionView;
@synthesize sectionIndices = _sectionIndices;
@synthesize sectionWidth = _sectionWidth;

-(void)scrollToOffset:(CGFloat)offset
{
//    [_scrollView setContentOffset:offset animated:YES];
    CGPoint OffsetPoint = _scrollView.contentOffset;
    OffsetPoint.x = offset;
    [_scrollView setContentOffset:OffsetPoint ];
    [self layoutIfNeeded];
}

-(void)setSectionView:(HorizontalTableView *)sectionView
{
    [_sectionView release];
    _sectionView = [sectionView retain];
    _currentSection = 0;
    _sectionWidth = [sectionView.delegate columnWidthForTableView:sectionView];
}

- (void)refreshData {
    self.pageViews = [NSMutableArray array];
	// to save time and memory, we won't load the page views immediately
	NSUInteger numberOfPhysicalPages = [self numberOfPages];
	for (NSUInteger i = 0; i < numberOfPhysicalPages; ++i)
		[self.pageViews addObject:[NSNull null]];
    
    [self setNeedsLayout];
}

- (NSUInteger)numberOfPages
{
	NSInteger numPages = 0;
    if (_delegate)
        numPages = [_delegate numberOfColumnsForTableView:self];
    return numPages;
}

- (UIView *)viewForPhysicalPage:(NSUInteger)pageIndex
{
	NSParameterAssert(pageIndex >= 0);
	NSParameterAssert(pageIndex < [self.pageViews count]);
	
	UIView *pageView;
	if ([self.pageViews objectAtIndex:pageIndex] == [NSNull null]) {
        
        if (_delegate) {
            pageView = [_delegate tableView:self viewForIndex:pageIndex];
            [self.pageViews replaceObjectAtIndex:pageIndex withObject:pageView];
            [self.scrollView addSubview:pageView];
            DLog(@"View loaded for page %d", pageIndex);
        }
	} else {
		pageView = [self.pageViews objectAtIndex:pageIndex];
	}
	return pageView;
}

- (CGSize)pageSize {
    CGRect rect = self.scrollView.bounds;
	return rect.size;
}

- (CGFloat)columnWidth
{
    if (!_columnWidth)
    {
        if (_delegate)
        {
            CGFloat width = [_delegate columnWidthForTableView:self];
            _columnWidth = [[NSNumber numberWithFloat:width] retain];
        }
    }
    return [_columnWidth floatValue];

}

- (BOOL)isPhysicalPageLoaded:(NSUInteger)pageIndex
{
	return [self.pageViews objectAtIndex:pageIndex] != [NSNull null];
}

- (void)layoutPhysicalPage:(NSUInteger)pageIndex
{
	UIView *pageView = [self viewForPhysicalPage:pageIndex];
    CGFloat viewWidth = pageView.bounds.size.width;
	CGSize pageSize = [self pageSize];
    
    CGRect rect = CGRectMake(viewWidth * pageIndex, 0, viewWidth, pageSize.height);
	pageView.frame = rect;
}

- (void)awakeFromNib {
    [self prepareView];
}

- (void)queueColumnView:(UIView *)vw
{
    if ([self.columnPool count] >= kColumnPoolSize)
    {
        return;
    }
    [self.columnPool addObject:vw];
}

- (UIView *)dequeueColumnView {
    UIView *vw = [[self.columnPool lastObject] retain];
    if (vw) {
        [self.columnPool removeLastObject];
        DLog(@"Supply from reuse pool");
    }
    return [vw autorelease];
}

- (void)removeColumn:(NSInteger)index {
    if ([self.pageViews objectAtIndex:index] != [NSNull null]) {
        DLog(@"Removing view at position %d", index);
        UIView *vw = [self.pageViews objectAtIndex:index];
        [self queueColumnView:vw];
        [vw removeFromSuperview];
        [self.pageViews replaceObjectAtIndex:index withObject:[NSNull null]];
    }
}

- (void)currentPageIndexDidChange {
    CGSize pageSize = [self pageSize];
    CGFloat columnWidth = [self columnWidth];
    _visibleColumnCount = pageSize.width / columnWidth + 2;
    
    NSInteger leftMostPageIndex = -1;
    NSInteger rightMostPageIndex = 0;
    
    for (NSInteger i = -2; i < _visibleColumnCount; i++) {
        NSInteger index = _currentPhysicalPageIndex + i;
        if (index < [self.pageViews count] && (index >= 0)) {
            [self layoutPhysicalPage:index];
            if (leftMostPageIndex < 0)
                leftMostPageIndex = index;
            rightMostPageIndex = index;
        }
    }
    
    // clear out views to the left
    for (NSInteger i = 0; i < leftMostPageIndex; i++) {
        [self removeColumn:i];
    }
    
    // clear out views to the right
    for (NSInteger i = rightMostPageIndex + 1; i < [self.pageViews count]; i++) {
        [self removeColumn:i];
    }
 
}

- (void)layoutPages {
    CGSize pageSize = self.bounds.size;
	self.scrollView.contentSize = CGSizeMake([self.pageViews count] * [self columnWidth], pageSize.height);
}

- (id)init {
    self = [super init];
    if (self) {
        [self prepareView];
    }
    return self;
}

- (void)prepareView {
	_columnPool = [[NSMutableArray alloc] initWithCapacity:kColumnPoolSize];
    _columnWidth = nil;
    
    [self setClipsToBounds:YES];
    
    self.autoresizesSubviews = YES;
    
    _currentSection = 0;

    UIScrollView *scroller = [[UIScrollView alloc] init];
    CGRect rect = self.bounds;
    scroller.frame = rect;
    scroller.backgroundColor = [UIColor blackColor];
	scroller.delegate = self;
    scroller.autoresizesSubviews = YES;
    scroller.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
	//self.scrollView.pagingEnabled = YES;
	scroller.showsHorizontalScrollIndicator = YES;
	scroller.showsVerticalScrollIndicator = NO;
    scroller.alwaysBounceVertical = NO;
    self.scrollView = scroller;
	[self addSubview:scroller];
    [scroller release], scroller = nil;
    _sectionOffsets = [[NSMutableArray alloc]initWithCapacity:32];

    if (self.sectionIndices)
    {
        for (int i=0; i<self.sectionIndices.count; i++)
        {
            CGFloat w = [self columnWidth]*[_sectionIndices[i] intValue];
            [_sectionOffsets addObject:@(w)];
        }
    }
    
    UITapGestureRecognizer* tap = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)] autorelease];
    [self.scrollView addGestureRecognizer:tap];
}


-(NSInteger)columnForLocation:(CGPoint)p
{
    return (NSInteger)(p.x/[self columnWidth]);
}

-(void)tapped:(UIGestureRecognizer*)greg
{
    CGPoint p = [greg locationInView:self.scrollView];
    NSLog(@"Tapped @{%f, %f}", p.x, p.y);
    //TODO: We can do the selectedDelegation here.
    [self.delegate didSelectColumn:[self columnForLocation:p]];
}

-(void)setSectionIndices:(NSArray *)sectionIndices
{
    [_sectionOffsets removeAllObjects];
//    _sectionIndices = [NSMutableArray arrayWithArray:sectionIndices];
    for (int i=0; i<sectionIndices.count; i++)
    {
        CGFloat w = [self columnWidth]*[sectionIndices[i] intValue];
        [_sectionOffsets addObject:@(w)];
    }

}


- (NSUInteger)physicalPageIndex {
    NSUInteger page = self.scrollView.contentOffset.x / [self columnWidth];
    return page;
}

- (void)setPhysicalPageIndex:(NSUInteger)newIndex {
	self.scrollView.contentOffset = CGPointMake(newIndex * [self pageSize].width, 0);
}

-(void) currentSectionDidStartTransite:(float)ratus
{
    if (self.sectionView)
    {
        float offset        = self.sectionWidth*(ratus + _currentSection);
        [self.sectionView scrollToOffset:offset];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate methods

int signum(float n) { return (n < 0) ? -1 : (n > 0) ? +1 : 0; }

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.sectionView)
    {
        float start = scrollView.contentOffset.x;
        float end   = start + self.sectionWidth;
        float pole = [_sectionOffsets[_currentSection] floatValue];
        float ratus = 0.0;
        NSInteger nextSection = _currentSection;
        
        if (pole < start)
        {
            //We are pulling left
            float nextPole = [_sectionOffsets[nextSection] floatValue];
            while (nextPole < start && nextPole >= pole && nextSection < _sectionOffsets.count)
            {
                _currentSection = nextSection++;
                if (nextSection>=_sectionOffsets.count) {
                    break;
                }
                nextPole = [_sectionOffsets[nextSection] floatValue];
            }
            
            if (nextPole >= start && nextPole <= end)
                ratus = (end-nextPole)/(end-start);
        }
        else
        {
            //We are pulling right
            do {
                if (nextSection == 0) {
                    break;
                if (pole <= end)
                    ratus = (end-pole)/(end-start);
                }
                pole =[_sectionOffsets[--nextSection] floatValue];
            } while (pole >= start && nextSection >= 0);
            _currentSection = nextSection;
        }
        [self currentSectionDidStartTransite:ratus];

    }
    
	NSUInteger newPageIndex = self.physicalPageIndex;
	if (newPageIndex == _currentPhysicalPageIndex) return;
	_currentPhysicalPageIndex = newPageIndex;
	_currentPageIndex = newPageIndex;
	
	[self currentPageIndexDidChange];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	DLog(@"scrollViewDidEndDecelerating");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)layoutSubviews {
    [self layoutPages];
    [self currentPageIndexDidChange];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	// adjust frames according to the new page size - this does not cause any visible changes
	[self layoutPages];
	self.physicalPageIndex = _currentPhysicalPageIndex;
	
	// unhide
	for (NSUInteger pageIndex = 0; pageIndex < [self.pageViews count]; ++pageIndex)
		if ([self isPhysicalPageLoaded:pageIndex])
			[self viewForPhysicalPage:pageIndex].hidden = NO;
	
    self.scrollView.contentSize = CGSizeMake([self.pageViews count] * [self columnWidth], [self pageSize].height);

    [self currentPageIndexDidChange];
}


- (void)dealloc {
    [_columnPool release], _columnPool = nil;
    [_columnWidth release], _columnWidth = nil;
    [_pageViews release], _pageViews = nil;
    [_scrollView release], _scrollView = nil;
    [super dealloc];
}

@end
