//
//  PNBPage.h
//  PhotoNoteBook
//
//  Created by 안 진섭 on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// Note의 상태를 표시하기 위한 값으로
// PNBDocument에서 상태를 변경한다.
enum {
    PNBPageStatusNormal = 0,
    PNBPageStatusAdded,
    PNBPageStatusDeleted,
    PNBPageStatusModified
};

typedef NSInteger PNBPageStatus;


// 페이지 정보를 보관한 클래스
@interface PNBPage : NSObject < NSCoding >

// 이미지로 객체 초기화
- (id) initWithImage:(NSImage *)image;


// 페이지 제목
@property (nonatomic, strong) NSString *title;

// 페이지 생성 시간
@property (nonatomic, strong) NSDate *ctime;

// Note에 그림 페이지
@property (nonatomic, strong) NSImage *photo;

// photo의 썸네임
@property (nonatomic, strong) NSImage *thumbnail;

// 페이지 객체의 현재 상태 표시
@property (nonatomic, assign) PNBPageStatus status;

// 임시 테그값 저장
// 다른 객체와 잠시 연결시키기 위한
@property (nonatomic, assign) id tag;


@end
