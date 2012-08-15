//
//  PNBDocument.m
//  PhotoNoteBookForMac
//
//  Created by jinni on 8/11/12.
//  Copyright (c) 2012 jinni. All rights reserved.
//

#import "PNBDocument.h"
#import "PNBNoteMetadata.h"
#import "PNBPage.h"
#import "NSImage+Resize.h"


@implementation PNBDocument
{
    NSMutableArray *deletedPageList;
}



@synthesize tableView = _tableView;
@synthesize imageView = _imageView;
@synthesize btnDelPage = _btnDelPage;

@synthesize fileWrapper = _fileWrapper;
@synthesize metadata = _metadata;
@synthesize pages = _pages;


- (id)init
{
    self = [super init];
    if (self) {
        // 초기화
        self.fileWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil];
        self.metadata = [[PNBNoteMetadata alloc] init];
        self.pages = [[NSMutableArray alloc] initWithCapacity:10];

        deletedPageList = [[NSMutableArray alloc] initWithCapacity:10];
        NSFileWrapper *photoDir = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil];
        photoDir.preferredFilename = @"photo";
        [self.fileWrapper addFileWrapper:photoDir];
    }
    return self;
}

- (NSString *)windowNibName
{
    return @"PNBDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

// 사진 정보를 통해서 페이지 등록
- (void) addPageWithPhoto:(NSImage*) photo
                withTitle:(NSString*) title
{
    // 페이지 생성
    PNBPage *page = [[PNBPage alloc] initWithImage:photo];
    page.title = title;
    page.thumbnail = [photo imageByScalingAndCroppingForSize:CGSizeMake(145, 145)];
    
    // 페이지 섬네일이 없으면 첫번째 등록된 것으로 하도록.
    if (! self.metadata.thumbnail) {
        self.metadata.thumbnail = page.thumbnail;
    }
    page.status = PNBPageStatusAdded;
    
    [self addPage:page];

}

// 페이지 객체를 내부 모델 객체에 저장한다.
// 아직 실제로 파일에 저장되는 것은 아니다. 
- (void) addPage:(PNBPage*)page
{
    [self.pages addObject:page];
    
    // Undo 등록
    [self.undoManager beginUndoGrouping];
    [[self.undoManager prepareWithInvocationTarget:self.tableView] reloadData];
    [[self.undoManager prepareWithInvocationTarget:self] removePage:page];
    [self.undoManager setActionName:@"add page"];
    [self.undoManager endUndoGrouping];
    
    [self.tableView reloadData];
    
}



- (void) removePageAtIndex:(NSInteger)index
{
    PNBPage *page = [self.pages objectAtIndex:index];
    
    // 페이지 삭제
    [self removePage:page];
}

- (void) removePage:(PNBPage*) page
{
    [deletedPageList addObject:page];
    [self.pages removeObject:page];
    
    // Undo 등록
    [self.undoManager beginUndoGrouping];
    [[self.undoManager prepareWithInvocationTarget:self.tableView] reloadData];
    [[self.undoManager prepareWithInvocationTarget:deletedPageList] removeObject:page];
    [[self.undoManager prepareWithInvocationTarget:self] addPage:page];
    [self.undoManager setActionName:@"delete page"];
    [self.undoManager endUndoGrouping];
    
    // 테이블 다시 로드
    [self.tableView reloadData];
    
}


-(NSFileWrapper *)fileWrapperOfType:(NSString *)typeName
                              error:(NSError *__autoreleasing *)outError
{
    // .... 생략 ....
    
    // 추가한 Page 추가
    [self.pages enumerateObjectsUsingBlock:^(PNBPage *page, NSUInteger idx, BOOL *stop) {
        if (page.status == PNBPageStatusAdded) {

            // filewrapper 생성
            NSString* filename = [self uniqueFilename];
            [self encodeObject:page toWrappers:[self fileWrapperForPhotoDir] preferredFilename:filename];
            NSFileWrapper *fileWrapper = [[[self fileWrapperForPhotoDir] fileWrappers] objectForKey:filename];
            
            page.tag = fileWrapper;
            page.status = PNBPageStatusNormal;
        }
    }];
    
    // .... 생략 ....

    return self.fileWrapper;
}

#define kEncodeDecodeKey @"data"

-(BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper
                    ofType:(NSString *)typeName
                     error:(NSError *__autoreleasing *)outError
{
    
    // 데이터 로드
    self.fileWrapper = fileWrapper;
    
    // 메타 데이터
    self.metadata = [self decodeObjectFromWrapper:self.fileWrapper
                            WithPreferredFilename:@"meta.plist"];
    
    // 노트 데이터
    [self.pages removeAllObjects];
    NSFileWrapper *dir = [self fileWrapperForPhotoDir];
    for (NSString *key in [[dir fileWrappers] allKeys]) {
        PNBPage *page = [self decodeObjectFromWrapper:dir
                                WithPreferredFilename:key];
        
        // page 객체와 filewrapper ( 실제 파일 )을 연결한다.
        page.tag = [[[self fileWrapperForPhotoDir] fileWrappers] objectForKey:key];
        [self.pages addObject:page];
    }
    
    // 테이블 다시 로드 
    [self.tableView reloadData];
    
    // undo 스텍 초기화
    // 저장 이후에는 undo/redo 기록을 지운다.
    [self.undoManager removeAllActions];

    return YES;
}

//
// Helper Function for adding or extracting data
//

#define kEncodeDecodeKey @"data"

// 주어진 파일 이름으로 fileWrapper에서 데이터를 찾아서
// 객체화 시키는 메소드
- (id)decodeObjectFromWrapper:(NSFileWrapper*)fileWrappers
        WithPreferredFilename:(NSString *)preferredFilename {
    
    // 파일명에 해당하는 fileWrapper 객체를 구한다.
    // 여기서 fileWrapper는 하나의 파일이라고 생각해도 무방
    NSFileWrapper * fileWrapper = [[fileWrappers fileWrappers]
                                   objectForKey:preferredFilename];
    if (!fileWrapper) {
        NSLog(@"[ERROR] Cannot find file (%@) in file wrapper", preferredFilename);
        return nil;
    }
    
    // Extract Data
    // NSKeyedUnarchiver를 읽고 이용해서 데이터를 객체화 한다.

    NSData * data = [fileWrapper regularFileContents];
    NSKeyedUnarchiver * unarchiver = [[NSKeyedUnarchiver alloc]
                                      initForReadingWithData:data];
    return [unarchiver decodeObjectForKey:kEncodeDecodeKey];
    
}

// 데이터를 fileWrapper에 저장.
// 데이터는 NSFileWrapper로 만들어지고 이렇게 만들어진 NSFileWrapper는 최종 파일로 만들어진다.
// 파일로 만드는 것은 UIDocument의 다른 내부 메소드가 수행.
// 여기서는 fileWrapper를 만드는 것
- (void)encodeObject:(id<NSCoding>)object
          toWrappers:(id)wrappers
   preferredFilename:(NSString *)preferredFilename
{
    // 저장할 데이터 생성
    NSMutableData * data = [NSMutableData data];
    NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc]
                                  initForWritingWithMutableData:data];
    [archiver encodeObject:object forKey:kEncodeDecodeKey];
    [archiver finishEncoding];
    
    // wrappers가 NSDictionary 혹은 NSFileWrapper가 될 수 있다.
    // 따라서 각기 다른 방법으로 추가
    BOOL isFileWrapper = [wrappers isKindOfClass:[NSFileWrapper class]];
    BOOL isDirectory = [wrappers isKindOfClass:[NSDictionary class]];
    
    if(isFileWrapper){
        [wrappers addRegularFileWithContents:data
                           preferredFilename:preferredFilename];
    } else if( isDirectory ){
        NSFileWrapper * wrapper = [[NSFileWrapper alloc]
                                   initRegularFileWithContents:data];
        [wrappers setObject:wrapper forKey:preferredFilename];
    }
}

#define kMetaFileName @"meta.plist"

- (NSString *) uniqueFilename
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    
    NSString *uuidString = [NSString stringWithString:(__bridge NSString *) uuidStringRef];
    CFRelease(uuidStringRef);
    return uuidString;
}

// NSFileWrapper를 통해서 만들어진 폴더 구조는 다음과 같다.
// ex)
//
// xxxx.note
//   - meta.plist    :  Note 메타 정보
//   - photo         : 사진을 저장할 폴더
//       - xxxxxxxx1 : 사진
//       - xxxxxxxx2 : 사진
//       -   ...
//
// photo 폴더에 해당하는 fileWrapper를 반환한다.
//
- (NSFileWrapper*) fileWrapperForPhotoDir
{
    return [[self.fileWrapper fileWrappers] objectForKey:@"photo"];
}


#pragma mark - NSTableDataSource handler

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.pages.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{

    PNBPage *page = [self.pages objectAtIndex:row];

    if( [[tableColumn identifier] isEqualToString:@"thumb"] )
    {
        // thumb column
        return page.thumbnail;
    } else {
        // title column
        return [page.ctime description];
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    long row = [self.tableView selectedRow];
    PNBPage *page = [self.pages objectAtIndex:row];

    if( 0 <= row && row < self.pages.count )
        self.imageView.image = page.photo;
    else
        self.imageView.image = nil;
    
    // 테이블에서 선택이 되면 버튼 활성화
    [self.btnDelPage setEnabled:row != -1];
}


#pragma mark - Handlers

- (IBAction)AddImageFromMac:(id)sender
{
    // 파일을 선택할 화면 생성
    NSOpenPanel *openPanel	= [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setResolvesAliases:YES];
    [openPanel setAllowedFileTypes:@[@"png",@"jpeg",@"jpg",@"bmp"]];
    [openPanel setMessage:@"Choose image for adding"];
    
    NSInteger rev	= [openPanel runModal];
    if(rev != NSOKButton){
        return;
    }
    
    // called if click 'YES'
    NSURL *url = [openPanel URL];
    
    // input image to file
    NSImage *targetImg = [[NSImage alloc] initWithContentsOfURL:url];
    [self addPageWithPhoto:targetImg withTitle:[url lastPathComponent]];
}


- (IBAction)deletePage:(id)sender
{
    // 테이블 뷰에서 선택한 셀 알아내기
    long row = self.tableView.selectedRow;

    // 셀 삭제
    if(0 <= row && row < self.pages.count)
        [self removePageAtIndex:row];
}

@end
