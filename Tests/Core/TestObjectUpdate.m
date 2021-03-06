/*
    Copyright (C) 2013 Quentin Mathe

    Date:  October 2013
    License:  MIT  (see COPYING)
 */

#import <UnitKit/UnitKit.h>
#import <EtoileFoundation/ETModelDescriptionRepository.h>
#import "TestCommon.h"

@interface TestObjectUpdateEntity : COObject
{
    NSString *_label;
    COMutableArray *_contents;
}

@property (nonatomic, readwrite, copy) NSString *label;
@property (nonatomic, readwrite, copy) NSArray *contents;

@end


@interface TestObjectUpdate : EditingContextTestCase
{
    id object;
    NSString *oldValue;
    NSString *newValue;
    id poster;
    int notificationCount;
}

@end


@interface TestIVarUpdate : TestObjectUpdate <UKTest>
@end


@interface TestIVarCollectionUpdate : TestObjectUpdate <UKTest>
@end


@interface TestVariableStorageUpdate : TestObjectUpdate <UKTest>
@end


@interface TestVariableStorageCollectionUpdate : TestObjectUpdate <UKTest>
@end


@interface TestDirectVariableStorageUpdate : TestObjectUpdate <UKTest>
@end


@implementation TestObjectUpdateEntity

// FIXME: Support @dynamic label, contents;
@synthesize label = _label, contents = _contents;

+ (ETEntityDescription *)newEntityDescription
{
    ETEntityDescription *entity = [self newBasicEntityDescription];

    if (![entity.name isEqual: [TestObjectUpdateEntity className]])
        return entity;

    ETPropertyDescription *label =
        [ETPropertyDescription descriptionWithName: @"label" typeName: @"NSString"];
    label.persistent = YES;
    ETPropertyDescription *contents =
        [ETPropertyDescription descriptionWithName: @"contents" typeName: @"NSString"];
    contents.persistent = YES;
    contents.multivalued = YES;
    contents.ordered = YES;

    entity.propertyDescriptions = @[label, contents];

    return entity;
}

- (instancetype)initWithObjectGraphContext: (COObjectGraphContext *)aContext
{
    self = [super initWithObjectGraphContext: aContext];
    if (self == nil)
        return nil;

    _contents = [COMutableArray new];
    return self;
}

- (void)setLabel: (NSString *)label
{
    [self willChangeValueForProperty: @"label"];
    _label = label;
    [self didChangeValueForProperty: @"label"];
}

- (void)setContents: (NSArray *)contents
{
    [self willChangeValueForProperty: @"contents"];
    _contents = [COMutableArray arrayWithArray: contents];
    [self didChangeValueForProperty: @"contents"];
}

@end


@implementation TestObjectUpdate

- (NSString *)property
{
    return nil;
}

- (id)oldValue
{
    return [NSNull null];
}

- (id)newValue
{
    return nil;
}

- (NSString *)entityName
{
    return @"TestObjectUpdateEntity";
}

- (void)observeValueForKeyPath: (NSString *)keyPath
                      ofObject: (id)anObject
                        change: (NSDictionary *)change
                       context: (void *)context
{
    if ([keyPath isEqual: [self property]])
    {
        oldValue = change[NSKeyValueChangeOldKey];
        newValue = change[NSKeyValueChangeNewKey];
        poster = anObject;
        notificationCount++;
    }
}

- (instancetype)init
{
    SUPERINIT;
    object = [ctx insertNewPersistentRootWithEntityName: [self entityName]].rootObject;
    [object addObserver: self
             forKeyPath: [self property]
                options: NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                context: NULL];
    ETAssert([self property] != nil);
    ETAssert([self oldValue] != nil);
    ETAssert([self newValue] != nil);
    if (![[self oldValue] isEqual: [NSNull null]])
    {
        [object setValue: [self oldValue] forStorageKey: [self property]];
    }
    return self;
}

- (void)dealloc
{
    [object removeObserver: self forKeyPath: [self property]];
}

- (void)validateKVOUpdate
{
    UKObjectsEqual([self oldValue], (oldValue != nil ? oldValue : [NSNull null]));
    UKObjectsEqual([self newValue], newValue);
    UKObjectsSame(object, poster);
    UKIntsEqual(1, notificationCount);
}

- (void)validateUpdate
{
    UKObjectsEqual([self newValue], [object valueForStorageKey: [self property]]);
    UKObjectsEqual([self newValue], [object valueForProperty: [self property]]);
    UKObjectsEqual([self newValue], [object valueForKey: [self property]]);

    [self validateKVOUpdate];
}

@end


// NOTE: A readwrite property bound a ivar must have a setter (synthesized or not)
@implementation TestIVarUpdate

- (NSString *)property
{
    return @"label";
}

- (id)newValue
{
    return @"Nobody";
}

- (void)testSetter
{
    ((TestObjectUpdateEntity *)object).label = [self newValue];

    [self validateUpdate];
}

- (void)testPVC
{
    [object setValue: [self newValue] forProperty: [self property]];

    [self validateUpdate];
}

- (void)testKVC
{
    [object setValue: [self newValue] forKey: [self property]];

    [self validateUpdate];
}

@end


@implementation TestIVarCollectionUpdate

- (NSString *)property
{
    return @"contents";
}

- (id)oldValue
{
    return @[@"bop", @"poum"];
}

- (id)newValue
{
    return @[@"bip", @"bop"];
}

- (void)testSetter
{
    ((OrderedAttributeModel *)object).contents = [self newValue];

    [self validateUpdate];
}

- (void)testPVC
{
    [object setValue: [self newValue] forProperty: [self property]];

    [self validateUpdate];
}

- (void)testKVC
{
    [object setValue: [self newValue] forKey: [self property]];

    [self validateUpdate];
}

@end


@implementation TestVariableStorageUpdate

- (NSString *)property
{
    return @"label";
}

- (id)newValue
{
    return @"Tree";
}

- (NSString *)entityName
{
    return @"OutlineItem";
}

- (void)testSetter
{
    [object setLabel: [self newValue]];

    [self validateUpdate];
}

- (void)testPVC
{
    [object setValue: [self newValue] forProperty: [self property]];

    [self validateUpdate];
}

- (void)testKVC
{
    [object setValue: [self newValue] forKey: [self property]];

    [self validateUpdate];
}

@end


@implementation TestVariableStorageCollectionUpdate

- (NSString *)property
{
    return @"contents";
}

- (id)oldValue
{
    return @[@"bop", @"poum"];
}

- (id)newValue
{
    return @[@"bip", @"bop"];
}

- (NSString *)entityName
{
    return @"OrderedAttributeModel";
}

- (void)testSetter
{
    ((OrderedAttributeModel *)object).contents = [self newValue];

    [self validateUpdate];
}

- (void)testPVC
{
    [object setValue: [self newValue] forProperty: [self property]];

    [self validateUpdate];
}

- (void)testKVC
{
    [object setValue: [self newValue] forKey: [self property]];

    [self validateUpdate];
}

@end


// NOTE: A readwrite property in the variable storage doesn't require a setter, 
// see -[COObject setValue:forUndefinedKey:].
@implementation TestDirectVariableStorageUpdate

- (NSString *)property
{
    return @"city";
}

- (id)newValue
{
    return @"Edmonton";
}

+ (void)addCityPropertyToEntity: (ETEntityDescription *)anEntity
{
    if (![anEntity.propertyDescriptionNames containsObject: @"city"])
    {
        ETEntityDescription *stringType =
            [[ETModelDescriptionRepository mainRepository] descriptionForName: @"NSString"];
        ETPropertyDescription *propertyDesc =
            [ETPropertyDescription descriptionWithName: @"city" type: stringType];

        [anEntity addPropertyDescription: propertyDesc];
    }
}

- (instancetype)init
{
    // N.B., We must add the 'city' property to COObject before registering
    // an observer for the 'city' key (done in [super init]), because we need
    // COObject to tell the KVO machinery that COObject will manually send
    // change notifications for the 'city' key (see +[COObject automaticallyNotifiesObserversForKey:]
    // and the [super didChangeValueForKey:] call in -[COObject didChangeValueForProperty]).
    //
    // If this was done after adding the KVO observer, KVO would do the dynamic
    // subclassing trick since it doesn't know that COObject will send manual KVO change
    // notifications for 'city', and we'd end up getting 2 notifications instead of 1 in -testKVC.

    // NOTE: The above comment no longer applies because you can't modify
    // an entity description after creating a COObject instance that uses it.

    [TestDirectVariableStorageUpdate addCityPropertyToEntity:
        [[ETModelDescriptionRepository mainRepository] entityDescriptionForClass: [TestObjectUpdateEntity class]]];

    SUPERINIT;
    return self;
}

- (void)testAbsentSetter
{
    UKFalse([object respondsToSelector: NSSelectorFromString(@"setCity:")]);
}

- (void)testPVC
{
    [object setValue: [self newValue] forProperty: [self property]];

    [self validateUpdate];
}

- (void)testKVC
{
    [object setValue: [self newValue] forKey: [self property]];

    [self validateUpdate];
}

@end
