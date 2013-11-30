#import <CoreObject/CoreObject.h>

@interface OutlineItem : COContainer

@property (nonatomic, readwrite) BOOL isShared;
@property (readwrite, strong, nonatomic) NSString *label;
@property (readwrite, strong, nonatomic) NSOrderedSet *contents;
@property (weak, readonly, nonatomic) OutlineItem *parentContainer;
@property (strong, readonly, nonatomic) NSSet *parentCollections;
@property (readwrite, nonatomic, getter=isChecked, setter=setChecked:) BOOL checked;
@property (readwrite, strong, nonatomic) COAttachmentID *attachmentID;

@end
