//
//  Table1.h
//  B312_BT_MIC_SPK
//
//  Created by EW on 16/5/12.
//  Copyright © 2016年 h. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Item.h"

@interface Table : NSViewController

//=============================================
@property(readwrite,copy)NSMutableArray* arrayDataSource;

@property (strong) IBOutlet NSView *custom;

@property (weak) IBOutlet NSScrollView *scrollview;
@property (weak) IBOutlet NSTableView *table;
//=============================================
- (id)init:(NSView*)parent DisplayData:(NSArray*)arrayData;

-(void)SelectRow:(int)rowindex;

-(void)flushTableRow:(Item*)item RowIndex:(NSInteger)rowIndex;

-(void)ClearTable;
//=============================================
@end
