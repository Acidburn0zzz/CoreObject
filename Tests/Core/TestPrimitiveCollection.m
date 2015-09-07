/*
    Copyright (C) 2013 Quentin Mathe, Eric Wasylishen

    Date:  April 2013
    License:  MIT  (see COPYING)
 */

#import <UnitKit/UnitKit.h>
#import <Foundation/Foundation.h>
#import "TestCommon.h"

@interface COMutableArray (TestPrimitiveCollection)
@property (nonatomic, readonly) NSIndexSet *deadIndexes;
@property (nonatomic, readonly) NSArray *deadReferences;
@property (nonatomic, readonly) NSArray *allReferences;
@end

@implementation COMutableArray (TestPrimitiveCollection)

- (NSIndexSet *)deadIndexes
{
	return [_backing.allObjects indexesOfObjectsPassingTest: ^(id obj, NSUInteger idx, BOOL *stop) {
		return [obj isKindOfClass: [COPath class]];
	}];
}

- (NSArray *)deadReferences
{
	return [_backing.allObjects objectsAtIndexes: [self deadIndexes]];
}

- (NSArray *)allReferences
{
	return _backing.allObjects;
}

@end

@interface TestMutableArray : NSObject <UKTest>
{
	COMutableArray *array;
	id alive1;
	id alive2;
	id alive3;
	id dead1;
	id dead2;
	id dead3;
	
}

@end

@implementation TestMutableArray

- (id)init
{
	SUPERINIT;
	array = [COMutableArray new];
	array.mutable = YES;
	alive1 = @"alive1";
	alive2 = @"alive2";
	alive3 = @"alive3";
	dead1 = [COPath pathWithPersistentRoot: [ETUUID UUID]];
	dead2 = [COPath pathWithPersistentRoot: [ETUUID UUID]];
	dead3 = [COPath pathWithPersistentRoot: [ETUUID UUID]];
	return self;
}

- (void)testEmptyCollection
{
	UKIntsEqual(0, array.count);
	UKFalse([array containsObject: @"something"]);
}

#pragma mark - Backing Operations

- (void)testAliveReferenceAddition
{
	[array addReference: alive1];
	
	UKTrue(array.deadIndexes.isEmpty);
	UKTrue(array.deadReferences.isEmpty);
	UKIntsEqual(1, array.count);
	UKObjectsEqual(alive1, [array objectAtIndex: 0]);
}

- (void)testDeadReferenceAddition
{
	[array addReference: dead1];
	
	UKObjectsEqual(INDEXSET(0), array.deadIndexes);
	UKObjectsEqual(A(dead1), array.deadReferences);
	UKObjectsEqual(A(dead1), array.allReferences);
	UKIntsEqual(0, array.count);
	UKFalse([array containsObject: dead1]);
	UKRaisesException([array objectAtIndex: 0]);
}

- (void)testDeadBeforeAliveReferenceAddition
{
	[array addReference: dead1];
	[array addReference: alive1];

	UKObjectsEqual(INDEXSET(0), array.deadIndexes);
	UKObjectsEqual(A(dead1), array.deadReferences);
	UKObjectsEqual(A(dead1, alive1), array.allReferences);
	UKIntsEqual(1, array.count);
	UKObjectsEqual(alive1, [array objectAtIndex: 0]);
	UKRaisesException([array objectAtIndex: 1]);
}

- (void)testDeadAfterAliveReferenceAddition
{
	[array addReference: alive1];
	[array addReference: dead1];
	
	UKObjectsEqual(INDEXSET(1), array.deadIndexes);
	UKObjectsEqual(A(dead1), array.deadReferences);
	UKObjectsEqual(A(alive1, dead1), array.allReferences);
	UKIntsEqual(1, array.count);
	UKObjectsEqual(alive1, [array objectAtIndex: 0]);
	UKRaisesException([array objectAtIndex: 1]);
}

- (void)testDeadAndAliveMixedReferenceAddition
{
	[array addReference: alive1];
	[array addReference: dead1];
	[array addReference: dead2];
	[array addReference: alive2];
	[array addReference: dead3];

	UKObjectsEqual(INDEXSET(1, 2, 4), array.deadIndexes);
	UKObjectsEqual(A(dead1, dead2, dead3), array.deadReferences);
	UKObjectsEqual(A(alive1, dead1, dead2, alive2, dead3), array.allReferences);
	UKIntsEqual(2, array.count);
	UKObjectsEqual(alive1, [array objectAtIndex: 0]);
	UKObjectsEqual(alive2, [array objectAtIndex: 1]);
	UKRaisesException([array objectAtIndex: 2]);
}

- (void)testDeadReferenceReplacement
{
	[array addReference: alive1];
	[array addReference: dead1];
	[array addReference: alive2];
	[array addReference: dead2];

	[array replaceReferenceAtIndex: 3 withReference: dead3];

	UKObjectsEqual(INDEXSET(1, 3), array.deadIndexes);
	UKObjectsEqual(A(dead1, dead3), array.deadReferences);
	UKObjectsEqual(A(alive1, dead1, alive2, dead3), array.allReferences);
	UKIntsEqual(2, array.count);
	UKObjectsEqual(alive1, [array objectAtIndex: 0]);
	UKObjectsEqual(alive2, [array objectAtIndex: 1]);
	UKRaisesException([array objectAtIndex: 2]);
}

- (void)testAliveReferenceReplacement
{
	[array addReference: alive1];
	[array addReference: dead1];
	[array addReference: alive2];
	[array addReference: dead2];
	
	[array replaceReferenceAtIndex: 2 withReference: alive3];
	
	UKObjectsEqual(INDEXSET(1, 3), array.deadIndexes);
	UKObjectsEqual(A(dead1, dead2), array.deadReferences);
	UKObjectsEqual(A(alive1, dead1, alive3, dead2), array.allReferences);
	UKIntsEqual(2, array.count);
	UKObjectsEqual(alive1, [array objectAtIndex: 0]);
	UKObjectsEqual(alive3, [array objectAtIndex: 1]);
	UKRaisesException([array objectAtIndex: 2]);
}

- (void)testDeadReferenceToAliveReplacementAtStart
{
	[array addReference: dead1];
	[array addReference: alive2];
	[array addReference: dead2];
	
	[array replaceReferenceAtIndex: 0 withReference: alive1];

	UKObjectsEqual(INDEXSET(2), array.deadIndexes);
	UKObjectsEqual(A(dead2), array.deadReferences);
	UKObjectsEqual(A(alive1, alive2, dead2), array.allReferences);
	UKIntsEqual(2, array.count);
	UKObjectsEqual(alive1, [array objectAtIndex: 0]);
	UKObjectsEqual(alive2, [array objectAtIndex: 1]);
	UKRaisesException([array objectAtIndex: 2]);
}

- (void)testDeadReferenceToAliveReplacementInMiddle
{
	[array addReference: alive1];
	[array addReference: dead1];
	[array addReference: alive3];
	[array addReference: dead2];
	
	[array replaceReferenceAtIndex: 1 withReference: alive2];
	
	UKObjectsEqual(INDEXSET(3), array.deadIndexes);
	UKObjectsEqual(A(dead2), array.deadReferences);
	UKObjectsEqual(A(alive1, alive2, alive3, dead2), array.allReferences);
	UKIntsEqual(3, array.count);
	UKObjectsEqual(alive1, [array objectAtIndex: 0]);
	UKObjectsEqual(alive2, [array objectAtIndex: 1]);
	UKObjectsEqual(alive3, [array objectAtIndex: 2]);
	UKRaisesException([array objectAtIndex: 3]);
}

- (void)testDeadReferenceToAliveReplacementAtEnd
{
	[array addReference: dead1];
	[array addReference: alive2];
	[array addReference: dead2];
	
	[array replaceReferenceAtIndex: 2 withReference: alive3];
	
	UKObjectsEqual(INDEXSET(0), array.deadIndexes);
	UKObjectsEqual(A(dead1), array.deadReferences);
	UKObjectsEqual(A(dead1, alive2, alive3), array.allReferences);
	UKIntsEqual(2, array.count);
	UKObjectsEqual(alive2, [array objectAtIndex: 0]);
	UKObjectsEqual(alive3, [array objectAtIndex: 1]);
	UKRaisesException([array objectAtIndex: 2]);
}

- (void)testAliveReferenceToDeadReplacementAtStart
{
	[array addReference: alive1];
	[array addReference: dead2];
	[array addReference: alive2];
	
	[array replaceReferenceAtIndex: 0 withReference: dead1];
	
	UKObjectsEqual(INDEXSET(0, 1), array.deadIndexes);
	UKObjectsEqual(A(dead1, dead2), array.deadReferences);
	UKObjectsEqual(A(dead1, dead2, alive2), array.allReferences);
	UKIntsEqual(1, array.count);
	UKObjectsEqual(alive2, [array objectAtIndex: 0]);
	UKRaisesException([array objectAtIndex: 1]);
}

- (void)testAliveReferenceToDeadReplacementInMiddle
{
	[array addReference: alive1];
	[array addReference: dead1];
	[array addReference: alive2];
	[array addReference: dead3];
	
	[array replaceReferenceAtIndex: 2 withReference: dead2];
	
	UKObjectsEqual(INDEXSET(1, 2, 3), array.deadIndexes);
	UKObjectsEqual(A(dead1, dead2, dead3), array.deadReferences);
	UKObjectsEqual(A(alive1, dead1, dead2, dead3), array.allReferences);
	UKIntsEqual(1, array.count);
	UKObjectsEqual(alive1, [array objectAtIndex: 0]);
	UKRaisesException([array objectAtIndex: 1]);
}

- (void)testAliveReferenceToDeadReplacementAtEnd
{
	[array addReference: alive1];
	[array addReference: dead1];
	[array addReference: alive2];
	
	[array replaceReferenceAtIndex: 2 withReference: dead2];
	
	UKObjectsEqual(INDEXSET(1, 2), array.deadIndexes);
	UKObjectsEqual(A(dead1, dead2), array.deadReferences);
	UKObjectsEqual(A(alive1, dead1, dead2), array.allReferences);
	UKIntsEqual(1, array.count);
	UKObjectsEqual(alive1, [array objectAtIndex: 0]);
	UKRaisesException([array objectAtIndex: 1]);
}

#pragma mark - Alive Objects Primitive Operations

- (void)testFirstObjectInsertion
{
	[array addReference: alive1];
	[array addReference: dead1];
	[array addReference: alive2];
	[array addReference: dead2];
	
	[array insertObject: alive3 atIndex: 0];
	
	UKObjectsEqual(INDEXSET(2, 4), array.deadIndexes);
	UKObjectsEqual(A(dead1, dead2), array.deadReferences);
	UKObjectsEqual(A(alive3, alive1, dead1, alive2, dead2), array.allReferences);
	UKIntsEqual(3, array.count);
	UKObjectsEqual(alive3, [array objectAtIndex: 0]);
	UKObjectsEqual(alive1, [array objectAtIndex: 1]);
	UKObjectsEqual(alive2, [array objectAtIndex: 2]);
	UKRaisesException([array objectAtIndex: 3]);
}

- (void)testMiddleObjectInsertion
{
	[array addReference: alive1];
	[array addReference: dead1];
	[array addReference: alive2];
	[array addReference: dead2];
	
	[array insertObject: alive3 atIndex: 1];
	
	UKObjectsEqual(INDEXSET(1, 4), array.deadIndexes);
	UKObjectsEqual(A(dead1, dead2), array.deadReferences);
	UKObjectsEqual(A(alive1, dead1, alive3, alive2, dead2), array.allReferences);
	UKIntsEqual(3, array.count);
	UKObjectsEqual(alive1, [array objectAtIndex: 0]);
	UKObjectsEqual(alive3, [array objectAtIndex: 1]);
	UKObjectsEqual(alive2, [array objectAtIndex: 2]);
	UKRaisesException([array objectAtIndex: 3]);
}

- (void)testLastObjectInsertion
{
	[array addReference: alive1];
	[array addReference: dead1];
	[array addReference: alive2];
	[array addReference: dead2];
	
	[array insertObject: alive3 atIndex: 2];
	
	UKObjectsEqual(INDEXSET(1, 3), array.deadIndexes);
	UKObjectsEqual(A(dead1, dead2), array.deadReferences);
	UKObjectsEqual(A(alive1, dead1, alive2, dead2, alive3), array.allReferences);
	UKIntsEqual(3, array.count);
	UKObjectsEqual(alive1, [array objectAtIndex: 0]);
	UKObjectsEqual(alive2, [array objectAtIndex: 1]);
	UKObjectsEqual(alive3, [array objectAtIndex: 2]);
	UKRaisesException([array objectAtIndex: 3]);
}

- (void)testFirstObjectRemoval
{
	[array addReference: alive1];
	[array addReference: dead1];
	[array addReference: alive2];
	[array addReference: dead2];
	[array addReference: alive3];
	
	[array removeObjectAtIndex: 0];
	
	UKObjectsEqual(INDEXSET(0, 2), array.deadIndexes);
	UKObjectsEqual(A(dead1, dead2), array.deadReferences);
	UKObjectsEqual(A(dead1, alive2, dead2, alive3), array.allReferences);
	UKIntsEqual(2, array.count);
	UKObjectsEqual(alive2, [array objectAtIndex: 0]);
	UKObjectsEqual(alive3, [array objectAtIndex: 1]);
	UKRaisesException([array objectAtIndex: 2]);
}

- (void)testMiddleObjectRemoval
{
	[array addReference: alive1];
	[array addReference: dead1];
	[array addReference: alive2];
	[array addReference: dead2];
	[array addReference: alive3];

	[array removeObjectAtIndex: 1];
	
	UKObjectsEqual(INDEXSET(1, 2), array.deadIndexes);
	UKObjectsEqual(A(dead1, dead2), array.deadReferences);
	UKObjectsEqual(A(alive1, dead1, dead2, alive3), array.allReferences);
	UKIntsEqual(2, array.count);
	UKObjectsEqual(alive1, [array objectAtIndex: 0]);
	UKObjectsEqual(alive3, [array objectAtIndex: 1]);
	UKRaisesException([array objectAtIndex: 2]);
}

- (void)testLastObjectRemoval
{
	[array addReference: alive1];
	[array addReference: dead1];
	[array addReference: alive2];
	[array addReference: dead2];
	[array addReference: alive3];

	[array removeObjectAtIndex: 2];
	
	UKObjectsEqual(INDEXSET(1, 3), array.deadIndexes);
	UKObjectsEqual(A(dead1, dead2), array.deadReferences);
	UKObjectsEqual(A(alive1, dead1, alive2, dead2), array.allReferences);
	UKIntsEqual(2, array.count);
	UKObjectsEqual(alive1, [array objectAtIndex: 0]);
	UKObjectsEqual(alive2, [array objectAtIndex: 1]);
	UKRaisesException([array objectAtIndex: 3]);
}

- (void)testFirstObjectReplacement
{
	[array addReference: alive1];
	[array addReference: dead1];
	[array addReference: alive2];
	[array addReference: dead2];
	
	[array replaceObjectAtIndex: 0 withObject: alive3];
	
	UKObjectsEqual(INDEXSET(1, 3), array.deadIndexes);
	UKObjectsEqual(A(dead1, dead2), array.deadReferences);
	UKObjectsEqual(A(alive3, dead1, alive2, dead2), array.allReferences);
	UKIntsEqual(2, array.count);
	UKObjectsEqual(alive3, [array objectAtIndex: 0]);
	UKObjectsEqual(alive2, [array objectAtIndex: 1]);
	UKRaisesException([array objectAtIndex: 2]);
}

- (void)testLastObjectReplacement
{
	[array addReference: alive1];
	[array addReference: dead1];
	[array addReference: alive2];
	[array addReference: dead2];
	
	[array replaceObjectAtIndex: 1 withObject: alive3];
	
	UKObjectsEqual(INDEXSET(1, 3), array.deadIndexes);
	UKObjectsEqual(A(dead1, dead2), array.deadReferences);
	UKObjectsEqual(A(alive1, dead1, alive3, dead2), array.allReferences);
	UKIntsEqual(2, array.count);
	UKObjectsEqual(alive1, [array objectAtIndex: 0]);
	UKObjectsEqual(alive3, [array objectAtIndex: 1]);
	UKRaisesException([array objectAtIndex: 2]);
}

#pragma mark - Alive Objects Additional Operations

/**
 * -addObject: must call -insertObject:atIndex: with a valid index when the
 * collection is empty.
 */
- (void)testFirstObjectAddition
{
	[array addObject: alive3];

	[array addReference: alive1];
	[array addReference: dead1];
	[array addReference: alive2];
	[array addReference: dead2];
	
	// Tests identical to -testFirstObjectInsertion
	UKObjectsEqual(INDEXSET(2, 4), array.deadIndexes);
	UKObjectsEqual(A(dead1, dead2), array.deadReferences);
	UKObjectsEqual(A(alive3, alive1, dead1, alive2, dead2), array.allReferences);
	UKIntsEqual(3, array.count);
	UKObjectsEqual(alive3, [array objectAtIndex: 0]);
	UKObjectsEqual(alive1, [array objectAtIndex: 1]);
	UKObjectsEqual(alive2, [array objectAtIndex: 2]);
	UKRaisesException([array objectAtIndex: 3]);
}

- (void)testLastObjectAddition
{
	[array addReference: alive1];
	[array addReference: dead1];
	[array addReference: alive2];
	[array addReference: dead2];
	
	[array addObject: alive3];

	// Tests identical to -testLastObjectInsertion
	UKObjectsEqual(INDEXSET(1, 3), array.deadIndexes);
	UKObjectsEqual(A(dead1, dead2), array.deadReferences);
	UKObjectsEqual(A(alive1, dead1, alive2, dead2, alive3), array.allReferences);
	UKIntsEqual(3, array.count);
	UKObjectsEqual(alive1, [array objectAtIndex: 0]);
	UKObjectsEqual(alive2, [array objectAtIndex: 1]);
	UKObjectsEqual(alive3, [array objectAtIndex: 2]);
	UKRaisesException([array objectAtIndex: 3]);
}

- (void)testRemoveLastObject
{
	[array addReference: alive1];
	[array addReference: dead1];
	[array addReference: alive2];
	[array addReference: dead2];
	[array addReference: alive3];
	
	[array removeLastObject];
	
	// Tests identical to -testLastObjectRemoval
	UKObjectsEqual(INDEXSET(1, 3), array.deadIndexes);
	UKObjectsEqual(A(dead1, dead2), array.deadReferences);
	UKObjectsEqual(A(alive1, dead1, alive2, dead2), array.allReferences);
	UKIntsEqual(2, array.count);
	UKObjectsEqual(alive1, [array objectAtIndex: 0]);
	UKObjectsEqual(alive2, [array objectAtIndex: 1]);
	UKRaisesException([array objectAtIndex: 3]);
}

- (void)testRemoveLastObjectWhenEmpty
{
	UKDoesNotRaiseException([array removeLastObject]);
}

@end

#pragma mark - TestUnsafeRetainedMutableArray

@interface DoOnDealloc : NSObject
{
	void (^doOnDeallocBlock)();
}
@end

@implementation DoOnDealloc

-(instancetype)initWithBlock:(void (^)())aDoOnDeallocBlock;
{
	SUPERINIT;
	doOnDeallocBlock = aDoOnDeallocBlock;
	return self;
}

- (void)dealloc
{
	doOnDeallocBlock();
}

@end



@interface TestUnsafeRetainedMutableArray : NSObject <UKTest>
{
	COUnsafeRetainedMutableArray *array;
}

@end

@implementation TestUnsafeRetainedMutableArray

- (id)init
{
	SUPERINIT;
	array = [COUnsafeRetainedMutableArray new];
	array.mutable = YES;
	return self;
}

- (void) testDoesNotRetain
{
	__block BOOL objectDealloced = NO;
	
	@autoreleasepool {
		DoOnDealloc *foo = [[DoOnDealloc alloc] initWithBlock: ^() {
			// This executes when this object is being deallocated
			objectDealloced = YES;
		}];
		
		[array addObject: foo];
		UKObjectsSame(foo, array[0]);
		UKFalse(objectDealloced);
	}
	
	UKTrue(objectDealloced);
}

- (void) testDisallowsDuplicates
{
	[array addObject: @"a"];
	[array addObject: @"b"];
	[array addObject: [NSString stringWithFormat: @"a"]];
	UKObjectsEqual(A(@"a", @"b"), array);
}

- (void) testAllowsReinsertion
{
	[array addObject: @"a"];
	UKObjectsEqual(A(@"a"), array);
	[array removeObject: @"a"];
	UKObjectsEqual(A(), array);
	[array addObject: @"a"];
	UKObjectsEqual(A(@"a"), array);
}

@end

#pragma mark - TestUnsafeRetainedMutableSet

@interface TestUnsafeRetainedMutableSet : NSObject <UKTest>
{
	COUnsafeRetainedMutableSet *set;
}

@end

@implementation TestUnsafeRetainedMutableSet

- (id)init
{
	SUPERINIT;
	set = [COUnsafeRetainedMutableSet new];
	set.mutable = YES;
	return self;
}

- (void) testDoesNotRetain
{
	__block BOOL objectDealloced = NO;
	
	@autoreleasepool {
		DoOnDealloc *foo = [[DoOnDealloc alloc] initWithBlock: ^() {
			// This executes when this object is being deallocated
			objectDealloced = YES;
		}];
		
		[set addObject: foo];
		UKIntsEqual(1, [set count]);
		UKFalse(objectDealloced);
	}
	
	UKTrue(objectDealloced);
}

- (void) testDisallowsDuplicates
{
	[set addObject: @"a"];
	[set addObject: @"b"];
	[set addObject: [NSString stringWithFormat: @"a"]];
	UKObjectsEqual(S(@"a", @"b"), set);
}

- (void) testAllowsReinsertion
{
	[set addObject: @"a"];
	UKObjectsEqual(S(@"a"), set);
	[set removeObject: @"a"];
	UKObjectsEqual(S(), set);
	[set addObject: @"a"];
	UKObjectsEqual(S(@"a"), set);
}

@end
