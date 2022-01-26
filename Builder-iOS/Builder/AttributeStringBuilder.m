//
//  AttributeStringBuilder.m
//  Builder-iOS
//
//  Created by niezhiqiang on 2022/1/26.
//

#import "AttributeStringBuilder.h"

#define kINVALID_SPACING_VALUE -1

@interface AttributeStringBuilder ()

@property (nonatomic, strong) NSMutableDictionary<NSAttributedStringKey, id> *attributes;
@property (nonatomic, strong) NSMutableAttributedString *source;
@property (nonatomic, assign) NSUInteger countOfLineBreaks;
@property (nonatomic, assign) CGFloat sourceLineSpacing;
@property (nonatomic, assign) CGFloat sourceSegmentSpacing;
@property (nonatomic, copy) NSAttributedString *imageString;
@property (nonatomic, copy) NSString *current;
@end

@implementation AttributeStringBuilder

#pragma mark - Private
- (instancetype)init {
    if (self = [super init]) {
        self.attributes = [[NSMutableDictionary alloc] init];
        self.source = [[NSMutableAttributedString alloc] init];
        self.countOfLineBreaks = 0;
        self.sourceLineSpacing = kINVALID_SPACING_VALUE;
        self.sourceSegmentSpacing = kINVALID_SPACING_VALUE;
    }
    return self;
}

- (NSMutableParagraphStyle *)paragraphStyle {
    NSMutableParagraphStyle *style = [self.attributes objectForKey:NSParagraphStyleAttributeName];
    if (!style) {
        style = [[NSMutableParagraphStyle alloc] init];
        [_attributes setObject:style forKey:NSParagraphStyleAttributeName];
    }
    return style;
}

- (NSAttributedString *)attributedString {
    return [[NSAttributedString alloc] initWithString:_current attributes:_attributes];
}

- (void)appendLineBreaks {
    for (int i = 0; i < _countOfLineBreaks; i++) {
        self.current = [_current stringByAppendingString:@"\n"];
    }
}

- (void)clean {
    self.current = nil;
    self.imageString = nil;
    self.countOfLineBreaks = 0;
    [self.attributes removeAllObjects];
}

#pragma mark - 文字样式
- (AttributeStringBuilder * _Nonnull (^)(NSString * _Nonnull))text {
    return ^AttributeStringBuilder* (NSString *attribute) {
        self.current = attribute;
        return self;
    };
}

- (AttributeStringBuilder * _Nonnull (^)(UIFont * _Nonnull))font {
    return ^AttributeStringBuilder* (UIFont *attribute) {
        [self.attributes setObject:attribute forKey:NSFontAttributeName];
        return self;
    };
}

- (AttributeStringBuilder * _Nonnull (^)(CGFloat))skew {
    return ^AttributeStringBuilder* (CGFloat attribute) {
        [self.attributes setObject:@(attribute) forKey:NSObliquenessAttributeName];
        return self;
    };
}

- (AttributeStringBuilder * _Nonnull (^)(UIColor * _Nonnull))color {
    return ^AttributeStringBuilder* (UIColor *attribute) {
        [self.attributes setObject:attribute forKey:NSForegroundColorAttributeName];
        return self;
    };
}

- (AttributeStringBuilder * _Nonnull (^)(UIColor * _Nonnull))mark {
    return ^AttributeStringBuilder* (UIColor *attribute) {
        [self.attributes setObject:attribute forKey:NSBackgroundColorAttributeName];
        return self;
    };
}

- (AttributeStringBuilder * _Nonnull (^)(UIColor * _Nonnull))underscore {
    return ^AttributeStringBuilder* (UIColor *attribute) {
        [self.attributes setObject:@(NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
        [self.attributes setObject:attribute forKey:NSUnderlineColorAttributeName];
        return self;
    };
}

- (AttributeStringBuilder * _Nonnull (^)(UIColor * _Nonnull))strikethrough {
    return ^AttributeStringBuilder* (UIColor *attribute) {
        [self.attributes setObject:@(NSUnderlineStyleSingle) forKey:NSStrikethroughStyleAttributeName];
        [self.attributes setObject:attribute forKey:NSStrikethroughColorAttributeName];
        return self;
    };
}

- (AttributeStringBuilder * _Nonnull (^)(CGFloat))wordSpacing {
    return ^AttributeStringBuilder* (CGFloat attribute) {
        [self.attributes setObject:@(attribute) forKey:NSKernAttributeName];
        return self;
    };
}

#pragma mark - 图片
- (AttributeStringBuilder * _Nonnull (^)(UIImage * _Nonnull, CGSize, CGFloat))image {
    return ^AttributeStringBuilder* (UIImage *attribute, CGSize size, CGFloat y) {
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = attribute;
        attachment.bounds = CGRectMake(0, y, size.width, size.height);
        self.imageString = [NSAttributedString attributedStringWithAttachment:attachment];
        return self;
    };
}

#pragma mark - 段落样式
- (AttributeStringBuilder * _Nonnull (^)(NSUInteger))wrap {
    return ^AttributeStringBuilder* (NSUInteger attribute) {
        self.countOfLineBreaks = attribute;
        return self;
    };
}

- (AttributeStringBuilder * _Nonnull (^)(NSTextAlignment))aligment {
    return ^AttributeStringBuilder* (NSTextAlignment attribute) {
        [self paragraphStyle].alignment = attribute;
        return self;
    };
}

- (AttributeStringBuilder * _Nonnull (^)(NSLineBreakMode))breakMode {
    return ^AttributeStringBuilder* (NSLineBreakMode attribute) {
        [self paragraphStyle].lineBreakMode = attribute;
        return self;
    };
}

- (AttributeStringBuilder * _Nonnull (^)(CGFloat))lineIndent {
    return ^AttributeStringBuilder* (CGFloat attribute) {
        [self paragraphStyle].firstLineHeadIndent = attribute;
        return self;
    };
}

- (AttributeStringBuilder * _Nonnull (^)(CGFloat))lineSpacing {
    return ^AttributeStringBuilder* (CGFloat attribute) {
        [self paragraphStyle].lineSpacing = attribute;
        return self;
    };
}

- (AttributeStringBuilder * _Nonnull (^)(CGFloat))segmentSpacing {
    return ^AttributeStringBuilder* (CGFloat attribute) {
        [self paragraphStyle].paragraphSpacing = attribute;
        return self;
    };
}

- (AttributeStringBuilder * (^)(NSString *urlString))link {
    return ^AttributeStringBuilder* (NSString *urlString) {
        NSURL * url = [NSURL URLWithString:urlString];
        [self.attributes setObject:url forKey:NSLinkAttributeName];
        return self;
    };
}

- (void)setLineSpacing:(CGFloat)spacing {
    self.sourceLineSpacing = spacing;
}

- (void)setSegmentSpacing:(CGFloat)spacing {
    self.sourceSegmentSpacing = spacing;
}

- (void (^)(void))commit {
    return ^void (void) {
        if (self.countOfLineBreaks > 0)
        {
            [self appendLineBreaks];
        }
        if (self.current) {
            NSAttributedString *string = [self attributedString];
            [self.source appendAttributedString:string];
        }
        if (self.imageString) {
            [self.source appendAttributedString:self.imageString];
        }
        [self clean];
    };
}

- (void (^)(void))commitImagePriority {
    return ^void (void) {
        if (self.countOfLineBreaks > 0)
        {
            [self appendLineBreaks];
        }
        if (self.imageString) {
            [self.source appendAttributedString:self.imageString];
        }
        if (self.current) {
            NSAttributedString *string = [self attributedString];
            [self.source appendAttributedString:string];
        }
        [self clean];
    };
}

- (NSAttributedString *)result {
    if (_sourceLineSpacing == kINVALID_SPACING_VALUE && _sourceSegmentSpacing == kINVALID_SPACING_VALUE) {
        return [_source copy];
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    if (_sourceLineSpacing != kINVALID_SPACING_VALUE) {
        [paragraphStyle setLineSpacing:_sourceLineSpacing];
    }
    if (_sourceSegmentSpacing != kINVALID_SPACING_VALUE) {
        [paragraphStyle setParagraphSpacing:_sourceSegmentSpacing];
    }
    [_source addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [_source length])];
    return [_source copy];
}

@end
