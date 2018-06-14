Class {
	#name : #TMUseOriginalGlobalMigrator,
	#superclass : #TMGlobalMigrator,
	#category : #Transactions
}

{ #category : #migrating }
TMUseOriginalGlobalMigrator >> migrateClassState: oldClass to: aClass [

	| slotsToMigrate |
	slotsToMigrate := aClass class allSlots reject: [ :e | Class hasSlotNamed: e name ].
	slotsToMigrate do: [ :newSlot | oldClass class slotNamed: newSlot name ifFound: [ :oldSlot | newSlot write: (oldSlot read: oldClass) to: aClass ] ].

	oldClass classVarNames
		do: [ :aClassVar | 
			(aClass hasClassVarNamed: aClassVar)
				ifTrue: [ aClass classVarNamed: aClassVar put: (oldClass classVarNamed: aClassVar) ] ]
]
