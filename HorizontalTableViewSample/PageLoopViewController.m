//
//  PageLoopViewController.m
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

#import "PageLoopViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation PageLoopViewController

@synthesize sectionTableView = _sectionTableView;
@synthesize columnView = _columnView;
@synthesize sectionView = _sectionView;

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.sectionTableView = nil;
    self.columnView = nil;
}

//- (void)dealloc
//{
//    [_sectionTableView release], _sectionTableView = nil;
//    [_columnView release], _columnView = nil;
//    [super dealloc];
//}

#pragma mark -

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    CALayer *layer = [self.sectionTableView layer];
    [layer setCornerRadius:10.0f];
    
    NSMutableArray *colorArray = [[NSMutableArray alloc] init];
    NSInteger step = [self numberOfSections];
    NSInteger columns = [self numberOfColumnsForSection:0];
    NSUInteger totalColor = 1000;
    for (NSInteger i = 0; i < totalColor; i += step) {
        CGFloat f = (float)i/totalColor;
        UIColor *clr = [UIColor colorWithRed:f green:f blue:f alpha:1.0f];
        [colorArray addObject:clr];
    }
    colors = colorArray;
    [self.sectionTableView setDelegate:self];
    [self.sectionTableView performSelector:@selector(refreshData) withObject:nil afterDelay:0.3f];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
    return YES;
}

#pragma mark -
#pragma mark SectionedHorizontalTableViewDelegate methods

-(NSUInteger)numberOfSections
{
    return 10;
}

-(NSUInteger)numberOfColumnsForSection:(NSUInteger)section
{
    return 10;
}

-(UIColor*)nextColor
{
    float rand = random()/RAND_MAX;
    return [UIColor colorWithRed:rand green:rand blue:rand alpha:1.0];
}

-(UIView *)tableView:(HorizontalTableView *)tableView viewForSection:(NSUInteger)s
{
    UIView* sect = [tableView dequeueColumnView];
    if (!sect) {
        NSLog(@"Section Constructing new view");
        [[NSBundle mainBundle] loadNibNamed:@"SectionView" owner:self options:nil];
        sect = self.sectionView;
        CGRect frame = sect.frame;
        frame.size.width = self.sectionTableView.frame.size.width;
        [sect setFrame:frame];
        self.sectionView = nil;
    }
    [sect setBackgroundColor:[UIColor redColor]];
    UILabel *lbl = (UILabel *)[sect viewWithTag:4321];
    lbl.text = [NSString stringWithFormat:@"Section %d", s];
    return sect;
}

-(UIView *)tableView:(HorizontalTableView *)tableView viewForColumn:(NSUInteger)c inSection:(NSUInteger)s
{
    UIView *vw = [tableView dequeueColumnView];
    if (!vw)
    {
        [[NSBundle mainBundle] loadNibNamed:@"ColumnView" owner:self options:nil];
        vw = self.columnView;
        self.columnView = nil;
        
    }
    [vw setBackgroundColor:[colors objectAtIndex:s*10+c]];

    UILabel *lbl = (UILabel *)[vw viewWithTag:1234];
    lbl.text = [NSString stringWithFormat:@"S%dC%d", s,c];
    
	return vw;
}

-(CGFloat)widthForColumn
{
    return 50.0f;
}

-(CGFloat)sectionHeight
{
    return 50;
}

-(CGFloat)sectionWidth
{
    return self.sectionTableView.frame.size.width;
}

-(void)didSelectColumn:(NSInteger)c atSection:(NSInteger)s
{
    NSLog(@"Selected item S%2dC%2d", s,c);
}
@end
