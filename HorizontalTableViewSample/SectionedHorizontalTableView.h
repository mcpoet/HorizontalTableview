//
//  SectionedHorizontalTableView.h
//  Scroller
//
//  Created by Steve on 14-2-15.
//
//

#import <UIKit/UIKit.h>
#import "HorizontalTableView.h"

@class SectionWrapper, SectionedHorizontalTableView;

typedef SectionedHorizontalTableView HorTableView;

@protocol SectionedTableViewDelegate
-(NSUInteger) numberOfSections;
-(NSUInteger) numberOfColumnsForSection:(NSUInteger)section;

-(UIView*) tableView:(HorizontalTableView*)tableView viewForSection:(NSUInteger)s;
-(UIView*) tableView:(HorizontalTableView *)tableView viewForColumn:(NSUInteger)c inSection:(NSUInteger)s;

-(CGFloat) widthForColumn;
-(CGFloat) sectionHeight;
-(CGFloat) sectionWidth;

- (void)didSelectColumn:(NSInteger)c atSection:(NSInteger)s;

@end

@interface SectionedHorizontalTableView : UIView<HorizontalTableViewDelegate>
{
    HorizontalTableView  * _sectionView;
    HorizontalTableView  * _tableView;
    NSObject<SectionedTableViewDelegate>* _delegate;
    
    SectionWrapper  * _sectionWrapper;
    
    NSMutableArray  * _sectionIndices;
    NSUInteger       _numberOfColumns;
}

@property (nonatomic, strong) IBOutlet NSObject<SectionedTableViewDelegate>* delegate;

- (NSInteger)numberOfColumnsForTableView:(HorizontalTableView *)tableView;
- (UIView *)tableView:(HorizontalTableView *)tableView viewForIndex:(NSInteger)index;
- (CGFloat)columnWidthForTableView:(HorizontalTableView *)tableView;
- (void)refreshData;

@end

@interface SectionWrapper : NSObject<HorizontalTableViewDelegate>
{
    SectionedHorizontalTableView* _s;
}
-(instancetype)initWithWrappee:(SectionedHorizontalTableView*)w;

- (NSInteger)numberOfColumnsForTableView:(HorizontalTableView *)tableView;
- (UIView *)tableView:(HorizontalTableView *)tableView viewForIndex:(NSInteger)index;
- (CGFloat)columnWidthForTableView:(HorizontalTableView *)tableView;

@end

