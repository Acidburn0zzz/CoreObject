#import "COEdit.h"
#import <EtoileFoundation/Macros.h>

#import "COEditGroup.h"
#import "COEditDeleteBranch.h"
#import "COEditUndeleteBranch.h"
#import "COEditSetBranchMetadata.h"
#import "COEditSetCurrentBranch.h"
#import "COEditSetCurrentVersionForBranch.h"
#import "COEditDeletePersistentRoot.h"
#import "COEditUndeletePersistentRoot.h"

// Edit types

static NSString * const kCOEditTypeEditGroup = @"COEditTypeEditGroup";
static NSString * const kCOEditTypeDeleteBranch = @"COEditTypeDeleteBranch";
static NSString * const kCOEditTypeUndeleteBranch = @"COEditTypeUndeleteBranch";
static NSString * const kCOEditTypeSetBranchMetadata = @"COEditTypeSetBranchMetadata";
static NSString * const kCOEditTypeSetCurrentBranch = @"COEditTypeSetCurrentBranch";
static NSString * const kCOEditTypeSetCurrentVersionForBranch = @"COEditTypeSetCurrentVersionForBranch";
static NSString * const kCOEditTypeDeletePersistentRoot = @"COEditTypeDeletePersistentRoot";
static NSString * const kCOEditTypeUndeletePersistentRoot = @"COEditTypeUndeletePersistentRoot";

// Edit properties

static NSString * const kCOEditType = @"COEditType";
static NSString * const kCOEditStoreUUID = @"COEditStoreUUID";
static NSString * const kCOEditPersistentRootUUID = @"COEditPersistentRootUUID";
static NSString * const kCOEditTimestamp = @"COEditTimestamp";

@implementation COEdit

+ (NSDictionary *) mapping
{
    return D([COEditGroup class], kCOEditTypeEditGroup,
           [COEditDeleteBranch class], kCOEditTypeDeleteBranch,
           [COEditUndeleteBranch class], kCOEditTypeUndeleteBranch,
           [COEditSetBranchMetadata class], kCOEditTypeSetBranchMetadata,
           [COEditSetCurrentBranch class], kCOEditTypeSetCurrentBranch,
           [COEditSetCurrentVersionForBranch class], kCOEditTypeSetCurrentVersionForBranch,
           [COEditDeletePersistentRoot class], kCOEditTypeDeletePersistentRoot,
           [COEditUndeletePersistentRoot class], kCOEditTypeUndeletePersistentRoot);
}

+ (COEdit *) editWithPlist: (id)aPlist
{
    NSString *type = [aPlist objectForKey: kCOEditType];
    
    // TODO: Allow for user defined types somehow
    
    Class cls = [[self mapping] objectForKey: type];

    if (cls != Nil)
    {
        return [[[cls alloc] initWithPlist: aPlist] autorelease];
    }
    else
    {
        [NSException raise: NSInvalidArgumentException format: @"invalid plist"];
        return nil;
    }
}

- (id) initWithPlist: (id)plist
{
    [NSException raise: NSInvalidArgumentException format: @"override"];
    return nil;
}

- (id) plist
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
 
    NSString *resultType = nil;
    NSDictionary *typeToClass = [COEdit mapping];
    for (NSString *type in typeToClass)
    {
        if ([self class] == [typeToClass objectForKey: type])
        {
            resultType = type;
        }
    }
    
    [result setObject: resultType forKey: kCOEditType];
    return result;
}

- (COEdit *) inverse
{
    [NSException raise: NSInvalidArgumentException format: @"override"];
    return nil;
}

- (BOOL) canApplyToContext: (COEditingContext *)aContext
{
    [NSException raise: NSInvalidArgumentException format: @"override"];
    return NO;
}

- (void) applyToContext: (COEditingContext *)aContext
{
    [NSException raise: NSInvalidArgumentException format: @"override"];
}

- (NSString *)description
{
    return [NSString stringWithFormat: @"<%@: %p> %@", [self class], self, [self plist]];
}

@end

@implementation COSingleEdit

@synthesize storeUUID = _storeUUID;
@synthesize persistentRootUUID = _persistentRootUUID;
@synthesize timestamp = _timestamp;

- (id) initWithPlist: (id)plist
{
    SUPERINIT;
    self.storeUUID = [ETUUID UUIDWithString: [plist objectForKey: kCOEditStoreUUID]];
    self.persistentRootUUID = [ETUUID UUIDWithString: [plist objectForKey: kCOEditPersistentRootUUID]];
    self.timestamp = [[[[NSDateFormatter alloc] init] autorelease] dateFromString: [plist objectForKey: kCOEditTimestamp]];
    return self;
}

- (id) plist
{
    NSMutableDictionary *result = [super plist];
    [result setObject: [_storeUUID stringValue] forKey: kCOEditStoreUUID];
    [result setObject: [_persistentRootUUID stringValue] forKey: kCOEditPersistentRootUUID];
    [result setObject: [[[[NSDateFormatter alloc] init] autorelease] stringFromDate: _timestamp] forKey: kCOEditTimestamp];
    return result;
}

- (id) copyWithZone:(NSZone *)zone
{
    COSingleEdit *aCopy = [[[self class] allocWithZone: zone] init];
    aCopy.storeUUID = _storeUUID;
    aCopy.persistentRootUUID = _persistentRootUUID;
    aCopy.timestamp = _timestamp;
    return aCopy;
}

@end