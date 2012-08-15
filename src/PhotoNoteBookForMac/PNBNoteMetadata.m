//
//  PNBNoteMetadata.m
//  PhotoNoteBook
//
//  Created by 안 진섭 on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PNBNoteMetadata.h"
#import "NSImage+Resize.h"

@implementation PNBNoteMetadata

@synthesize title = _title;
@synthesize thumbnail = _thumbnail;

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if(self) {
        self.title = title;
    }
    
    return self;
}

#pragma mark - NSCoding 

// 데이터에서 객체화 될때.
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    self.title = [aDecoder decodeObjectForKey:@"title"];
    
    self.thumbnailData = [aDecoder decodeObjectForKey:@"thumbnail"];
    NSImage *image = [[NSImage alloc] initWithData:self.thumbnailData];
    self.thumbnail = image;
    
    return self;
}
// 객체에서 데이터로 직렬화 될때
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if(!self.thumbnailData)
    {
        self.thumbnailData = [self.thumbnail PNGData];
    }
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.thumbnailData forKey:@"thumbnail"];
}

@end
