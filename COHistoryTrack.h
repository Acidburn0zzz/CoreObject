/*
	Copyright (C) 2010 Eric Wasylishen

	Author:  Eric Wasylishen <ewasylishen@gmail.com>, 
	         Quentin Mathe <quentin.mathe@gmail.com>
	Date:  November 2010
	License:  Modified BSD  (see COPYING)
 */

#import <Foundation/Foundation.h>
#import <EtoileFoundation/EtoileFoundation.h>
#import <ObjectMerging/COTrack.h>

@class CORevision, COObject, COStore;
@class COHistoryTrackNode;

/**
 * A history track is a view on the database of commits, presenting
 * them as a history graph. It is not persistent or cached in any way.
 *
 * It also allow exposes a simlpe NSUndoManager-like way of navigating
 * history.
 *
 * Undo/redo causes a new commit.
 * Similar idea as http://www.loria.fr/~weiss/pmwiki/uploads/Main/CollaborateCom.pdf
 */
@interface COHistoryTrack : COTrack
{
	NSSet *objects;
	// TODO: Remove trackObject ivar
	COObject *trackObject;
	BOOL includesInnerObjects;
	uint64_t revNumberAtCacheTime;
}

- (id)initWithTrackedObjects: (NSSet *)trackedObjects;

@property (assign, nonatomic) BOOL includesInnerObjects;

- (NSArray *)nodes;

/* Private */

- (COStore*)store;
- (BOOL)revisionIsOnTrack: (CORevision*)rev;
- (CORevision *)nextRevisionOnTrackAfter: (CORevision *)rev backwards: (BOOL)back;

@end


@interface COHistoryTrackNode : COTrackNode
{

}

/** @taskunit History Graph */

- (COHistoryTrackNode *)parent;
- (COHistoryTrackNode *)child;
- (NSArray *)secondaryBranches;

@end