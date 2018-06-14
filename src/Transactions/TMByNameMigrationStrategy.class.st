Class {
	#name : #TMByNameMigrationStrategy,
	#superclass : #TMMigrationStrategy,
	#category : #Transactions
}

{ #category : #'instance creation' }
TMByNameMigrationStrategy class >> for: newClass from: oldClass [ 

	^ self new
		newClass: newClass;
		oldClass: oldClass;
		yourself
]

{ #category : #testing }
TMByNameMigrationStrategy class >> isApplicableFor: newClass from: oldClass [ 
	
	(newClass allSlots size = oldClass allSlots size) ifFalse: [ ^ false ].
	newClass allSlots do: [ :aSlot | (oldClass hasSlotNamed: aSlot name) ifFalse: [ ^ false ]].
	
	^ true. 
]

{ #category : #migrating }
TMByNameMigrationStrategy >> migrateInstance: oldObject [ 
	| newObject |

	newObject := self createNewInstance: oldObject.
	self copyExistingSlotsFrom: oldObject to: newObject.

	^ newObject
]
