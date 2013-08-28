#import "COEditUndeletePersistentRoot.h"
#import "COEditDeletePersistentRoot.h"

#import "COEditingContext.h"
#import "COPersistentRoot.h"
#import "COBranch.h"

@implementation COEditDeletePersistentRoot

- (COEdit *) inverse
{
    COEditUndeletePersistentRoot *inverse = [[[COEditUndeletePersistentRoot alloc] init] autorelease];
    inverse.storeUUID = _storeUUID;
    inverse.persistentRootUUID = _persistentRootUUID;
    inverse.timestamp = _timestamp;
    return inverse;
}

- (BOOL) canApplyToContext: (COEditingContext *)aContext
{
    if (nil == [aContext persistentRootForUUID: _persistentRootUUID])
    {
        return NO;
    }
    return YES;
}

- (void) applyToContext: (COEditingContext *)aContext
{
    [[aContext persistentRootForUUID: _persistentRootUUID] setDeleted: YES];
}

@end