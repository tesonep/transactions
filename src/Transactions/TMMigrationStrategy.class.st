Class {
	#name : #TMMigrationStrategy,
	#superclass : #Object,
	#instVars : [
		'newClass',
		'oldClass'
	],
	#category : #Transactions
}

{ #category : #migrating }
TMMigrationStrategy >> copyExistingSlotsFrom: oldObject to: newObject. [

	newClass allSlots do: [ :newSlot | oldObject class slotNamed: newSlot name ifFound: [ :oldSlot | 
			newSlot write: (oldSlot read: oldObject) to: newObject ] ].

	newClass isVariable
		ifTrue: [ 1 to: oldObject basicSize do: [ :offset | newObject basicAt: offset put: (oldObject basicAt: offset) ] ].

]

{ #category : #migrating }
TMMigrationStrategy >> createNewInstance: oldObject [

	^ newClass isVariable
		ifTrue: [ newClass basicNew: oldObject size ]
		ifFalse: [ newClass basicNew ]
]

{ #category : #accessing }
TMMigrationStrategy >> newClass: aClass [ 

	newClass := aClass
]

{ #category : #accessing }
TMMigrationStrategy >> oldClass: aClass [ 
	
	oldClass := aClass
]
