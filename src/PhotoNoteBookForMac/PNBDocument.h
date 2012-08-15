//
//  PNBDocument.h
//  PhotoNoteBookForMac
//
//  Created by jinni on 8/11/12.
//  Copyright (c) 2012 jinni. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PNBNoteMetadata.h"
#import "PNBPage.h"

@interface PNBDocument : NSDocument < NSTableViewDataSource, NSTableViewDelegate >

/////// Views

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSButton *btnDelPage;


////// Handlers

// 페이지 삭제
- (IBAction)deletePage:(id)sender;
// 페이지 추가
- (IBAction)AddImageFromMac:(id)sender;



//////  Models

// 내부 데이터를 저장할 file wrapper
@property (nonatomic, strong) NSFileWrapper *fileWrapper;
// 노트의 메타 데이터
@property (nonatomic, strong) PNBNoteMetadata *metadata;
// 노트 정보들
@property (nonatomic, strong) NSMutableArray *pages;


@end
