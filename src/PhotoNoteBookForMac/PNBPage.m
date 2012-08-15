//
//  PNBPage.m
//  PhotoNoteBook
//
//  Created by 안 진섭 on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PNBPage.h"
#import "NSImage+Resize.h"

@interface PNBPage()

@property (nonatomic, strong) NSData *photoData;

@property (nonatomic, strong) NSData *thumbnailData;


@end

@implementation PNBPage

@synthesize title = _title;
@synthesize ctime = _ctime;
@synthesize photo = _photo;
@synthesize photoData = _photoData;
@synthesize thumbnail = _thumbnail;
@synthesize thumbnailData = _thumbnailData;
@synthesize status = _status;
@synthesize tag = _tag;

- (void)setTitle:(NSString *)title
{
    if (_title != title) {
        _title = title;
        _status = PNBPageStatusModified;
    }
}

- (void)setCtime:(NSDate *)ctime
{
    if (_ctime != ctime) {
        _ctime = ctime;
        _status = PNBPageStatusModified;
    }
}

- (void)setPhoto:(NSImage *)photo
{
    if (_photo != photo) {
        _photoData = nil;
        _photo = photo;
        _status = PNBPageStatusModified;
    }
}

- (void)setThumbnail:(NSImage *)thumbnail
{
    if (_thumbnail != thumbnail) {
        _thumbnailData = nil;
        _thumbnail = thumbnail;
        _status = PNBPageStatusModified;
    }
}

- (id) initWithImage:(NSImage *)image
{
    self.photo = image;
    self.thumbnail = nil;
    self.title = @"untitle";
    self.ctime = [NSDate date];
    self.status = PNBPageStatusNormal;
    return self;
}

#pragma mark - NSCoding 

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    self.thumbnailData = [aDecoder decodeObjectForKey:@"thumbnail"];
    self.thumbnail = [[NSImage alloc] initWithData:self.thumbnailData];

    self.photoData = [aDecoder decodeObjectForKey:@"photo"];
    self.photo = [[NSImage alloc] initWithData:self.photoData];
    self.ctime = [aDecoder decodeObjectForKey:@"ctime"];
    self.title = [aDecoder decodeObjectForKey:@"title"];
    self.status = PNBPageStatusNormal;

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    // 이미지를 로드했다고 다시 저장할때 이미지 손실이 없도록
    // 데이터가 있으면 이미지를 다시 파일로 만들지 않는다.
    if( ! self.thumbnailData )
    {
        self.thumbnailData = [self.thumbnail PNGData];
    }
    if( ! self.photoData )
    {
        self.photoData = [self.photo PNGData];
    }
    
    [aCoder encodeObject:self.thumbnailData forKey:@"thumbnail"];
    [aCoder encodeObject:self.photoData forKey:@"photo"];

    [aCoder encodeObject:self.ctime forKey:@"ctime"];
    [aCoder encodeObject:self.title forKey:@"title"];
    self.status = PNBPageStatusNormal;
}


@end
