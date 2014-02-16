//
//  SectionedHorizontalTableView.m
//  Scroller
//
//  Created by Steve on 14-2-15.
//
//

#import "SectionedHorizontalTableView.h"

#define kTABLEMARGIN 10
#define sDefaultSHeight 80

@implementation SectionWrapper

-(instancetype)initWithWrappee:(SectionedHorizontalTableView*)w
{
    self = [super init];
    if (self) {
        _s = [w retain];
    }
    return self;
}

-(void)dealloc
{
    [_s release]; _s = nil;
    [super dealloc];
}

-(NSInteger)numberOfColumnsForTableView:(HorizontalTableView *)tableView
{
    if (_s.delegate) {
        return [_s.delegate numberOfSections];
    }
    return 0;
}

-(UIView *)tableView:(HorizontalTableView *)tableView viewForIndex:(NSInteger)index
{
    if (_s.delegate)
    {
        NSUInteger uindex = index;
        return [_s.delegate tableView:tableView viewForSection:uindex];
    }
    return 0;
}

-(CGFloat)columnWidthForTableView:(HorizontalTableView *)tableView
{
    CGFloat w = _s.frame.size.width;
    NSLog(@"Section Width %f", w);
    return w;
}

-(void)didSelectColumn:(NSInteger)column
{
    
}

@end


@implementation SectionedHorizontalTableView
//@synthesize sectionView = _sectionView;
//@synthesize tableView   = _tableView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        [self setup];
    }
    return self;
}

-(void)awakeFromNib
{
    [self setup];
}

-(void)setup
{
    CGRect frame = [self frame];
    CGRect sframe = CGRectMake(0.0, 0.0, frame.size.width, sDefaultSHeight);
    CGRect tframe = CGRectMake(0.0, sDefaultSHeight+kTABLEMARGIN, frame.size.width, frame.size.height-sDefaultSHeight);
    
    _sectionView = [[HorizontalTableView alloc]init];
    [_sectionView setFrame:sframe];
    _tableView   = [[HorizontalTableView alloc] init];
    [_tableView setFrame:tframe];
    [self addSubview:_tableView];
    [self addSubview:_sectionView];
    [_tableView setDelegate:self];
    _sectionIndices = [[NSMutableArray alloc]init];
    if(self.delegate)
    {
        [self recomputeIndices];
        _sectionWrapper = [[SectionWrapper alloc]initWithWrappee:self];
        [_sectionView setDelegate:_sectionWrapper];
    }
    else
        _sectionWrapper = nil;
    [_tableView setSectionView:_sectionView];
    [_sectionView setUserInteractionEnabled:NO];
}

-(void)recomputeIndices
{
    NSUInteger s = [_delegate numberOfSections];
    [_sectionIndices removeAllObjects];
    _numberOfColumns = 0;
    [_sectionIndices addObject:@0];
    for (int i = 0; i<s; i++)
    {
        NSUInteger c = [_delegate numberOfColumnsForSection:i];
        _numberOfColumns += c;
        [_sectionIndices addObject:@(_numberOfColumns)];
    }
    [_tableView setSectionIndices:_sectionIndices];

}

-(void)setDelegate:(NSObject<SectionedTableViewDelegate>*)delegate
{
    [_delegate release], _delegate = nil;
    _delegate = [delegate retain];
    //Recompute the section indices
    if(_delegate)
    {
        [self recomputeIndices];
        [_sectionWrapper release], _sectionWrapper = nil;
        _sectionWrapper = [[SectionWrapper alloc]initWithWrappee:self];
        [_sectionView setDelegate:_sectionWrapper];
    }
}

-(void)refreshData
{
    [_sectionView refreshData];
    [_tableView refreshData];
}

//Here we have an Adaptor-Pattern like pattern.
//We devide the protocol interface into two categories for the same protocol,
//so we have to wrap it into some proxy object

#pragma HorizontalTableViewDelegate
- (NSInteger)numberOfColumnsForTableView:(HorizontalTableView *)tableView
{
    return _numberOfColumns;
}

-(NSInteger)devideSearch:(NSInteger)target array:(NSArray*)array found:(BOOL*)f
{
    *f = NO;
    NSUInteger start=0, mid=0, end=[array count];
    while ( end-start > 1)
    {
        mid = (start + end)/2;
        if (target > [array[mid] intValue])
            start = mid;
        else if (target < [array[mid] intValue])
            end = mid;
        else
        {
            *f = YES;
            return mid;
        }
    }
    return start;
}

- (UIView *)tableView:(HorizontalTableView *)tableView viewForIndex:(NSInteger)index
{
    if (!_delegate) return nil;
    BOOL result;
    NSInteger section = [self devideSearch:index array:_sectionIndices found:&result];
    NSInteger column = index - [_sectionIndices[section] intValue];
    return [_delegate tableView:tableView viewForColumn:column inSection:section];
}

- (CGFloat)columnWidthForTableView:(HorizontalTableView *)tableView
{
    if (!_delegate) return 0;
    return [_delegate widthForColumn];
}

-(void)didSelectColumn:(NSInteger)index
{
    if (_delegate)
    {
        BOOL r;
        NSInteger section = [self devideSearch:index array:_sectionIndices found:&r];
        NSInteger column = index - [_sectionIndices[section] intValue];
        [_delegate didSelectColumn:column atSection:section];
    }
}
@end

