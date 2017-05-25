//
//  CPTextField+CPAdditions.h
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 20.05.17.
//  Copyright (c) 2017 Patrick Kladek. All rights reserved.
//

#import "CrossPlatformDefinitions.h"

#if TARGET_OS_IPHONE
	@interface UILabel (CPAdditions)

	@property (nonatomic) NSString *identifier;
#else
	@interface NSTextField (CPAdditions)
#endif



- (void)cp_setText:(NSString *)string;
- (NSString *)cp_Text;

- (void)cp_setAlignment:(CPTextAlignment)alignment;
- (void)cp_setBordered:(BOOL)border;
- (void)cp_setBezeled:(BOOL)bezel;
- (void)cp_setEditable:(BOOL)editable;
- (void)cp_setSelectable:(BOOL)selectable;
- (void)cp_setNumberOfLines:(NSInteger)numberOfLines;

@end
