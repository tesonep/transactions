Class {
	#name : #TMBlockMigrationStrategy,
	#superclass : #TMMigrationStrategy,
	#instVars : [
		'migrationBlock'
	],
	#category : #Transactions
}

{ #category : #'instance creation' }
TMBlockMigrationStrategy class >> for: newClass from: oldClass using: aBlock [ 

	^ self new
		newClass: newClass;
		oldClass: oldClass;
		migrationBlock: aBlock;
		yourself.
]

{ #category : #migrating }
TMBlockMigrationStrategy >> migrateInstance: oldObject [
	| return newObject |

	newObject := self createNewInstance: oldObject.
	
	return := migrationBlock cull: self cull: oldObject cull: newObject.

	^ return class = newClass
		ifTrue: [ return ]
		ifFalse: [ newObject ]
]

{ #category : #accessing }
TMBlockMigrationStrategy >> migrationBlock: aBlock [ 
	
	migrationBlock := aBlock 
]
