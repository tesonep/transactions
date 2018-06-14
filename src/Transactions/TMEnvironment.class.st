Class {
	#name : #TMEnvironment,
	#superclass : #Object,
	#instVars : [
		'parent',
		'content',
		'evaluateClass',
		'migrationStrategies',
		'globalMigrators'
	],
	#category : #Transactions
}

{ #category : #'accessing environment' }
TMEnvironment >> associationAt: aName ifAbsent: aBlock [

	^ self content 
		associationAt: aName 
		ifAbsent: [ 
			(self parent includesKey: aName)
				ifTrue: [
					(self defaultClassNames includes: aName) 
						ifTrue: [ ^ self parent associationAt: aName ].
					 
					self copyClassNamed: aName.
					self content associationAt: aName ifAbsent: aBlock ]
				ifFalse: [ aBlock value]]
]

{ #category : #'accessing environment' }
TMEnvironment >> at: aClassName [

	^ self classNamed: aClassName
]

{ #category : #accessing }
TMEnvironment >> at: aString ifAbsent: aBlockClosure [ 
	^ self content at: aString ifAbsent: aBlockClosure
]

{ #category : #binding }
TMEnvironment >> bindingOf: aName [

	^ self associationAt: aName ifAbsent: [ nil ].
]

{ #category : #'commiting-rollback' }
TMEnvironment >> calculateMigrationStrategyFor: newClass from: oldClass [

	(self migrationStrategies includesKey: newClass name)
		ifTrue: [ ^ self migrationStrategies at: newClass name].
		
	(TMByNameMigrationStrategy isApplicableFor: newClass from: oldClass)
		ifTrue: [ ^ TMByNameMigrationStrategy for: newClass from: oldClass ].
		
	self error: 'Missing migration strategy'.
]

{ #category : #'accessing environment' }
TMEnvironment >> classNamed: aClassName [

	(self defaultClassNames includes: aClassName) ifTrue: [ ^ self parent at: aClassName ].
	^ self content at: aClassName ifAbsent: [ 
		(self parent includesKey: aClassName) 
			ifTrue:[ self copyClassNamed: aClassName ]
			ifFalse: [ nil ]].
]

{ #category : #'commiting-rollback' }
TMEnvironment >> commit [
	| classesToCommit oldObjects newObjects |
	classesToCommit := self content values reject: [ :e | e name = #EvaluateClass ].
	
	oldObjects := OrderedCollection new.
	newObjects := OrderedCollection new.
	
	classesToCommit do: [ :e | 
		
		(self parent includesKey: e name)
			ifTrue:[ | original |
				original := self parent at: e name.
				
				self commitGlobalState: e original: original.
				self commitInstancesOf: e original: original oldObjects: oldObjects newObjects: newObjects.
				
				oldObjects addAll: { original. original class }.
				newObjects addAll: { e. e class }]
			ifFalse: [ self parent at: e name put: e ]
	].

	classesToCommit do: [ :e | e environment: self parent ].

	oldObjects asArray elementsForwardIdentityTo: newObjects asArray
]

{ #category : #'commiting-rollback' }
TMEnvironment >> commitGlobalState: newClass original: oldClass [
	
	| slotsToCheck |
	
	self globalMigrators at: newClass name ifPresent: [:migrator | migrator migrateClassState: oldClass to: newClass. ^ self].
	
	(newClass class allSlots size = oldClass class allSlots size) ifFalse: [ self missingGlobalMigrator: newClass ].
	(newClass classVarNames size = oldClass classVarNames size) ifFalse: [ self missingGlobalMigrator: newClass ].
	
	(newClass class allSlots allSatisfy: [ :aSlot | oldClass class hasSlotNamed: aSlot name ]) ifFalse: [ self missingGlobalMigrator: newClass ].
	(newClass classVarNames allSatisfy: [ :aClassVar | (oldClass hasClassVarNamed: aClassVar) ]) ifFalse: [ self missingGlobalMigrator: newClass ].

	
	slotsToCheck := newClass class allSlots reject: [ :e | Class hasSlotNamed: e name ].
	(slotsToCheck allSatisfy: [ :newSlot | ((oldClass class slotNamed: newSlot name) read: oldClass) = (newSlot read: newClass) ])
		ifFalse: [ self missingGlobalMigrator: newClass ].
	
	(newClass classVarNames allSatisfy: [ :aClassVar | (newClass classVarNamed: aClassVar) = (oldClass classVarNamed: aClassVar) ])
		ifFalse: [ self missingGlobalMigrator: newClass ].
]

{ #category : #'commiting-rollback' }
TMEnvironment >> commitInstancesOf: newClass original: oldClass oldObjects: oldObjects newObjects: newObjects [

	| oldInstances migrationStrategy newInstances |

	oldInstances := oldClass allInstances.
	oldInstances ifEmpty: [ ^ self ].
	
	migrationStrategy := self calculateMigrationStrategyFor: newClass from: oldClass.
	newInstances := oldInstances collect: [ :e | migrationStrategy migrateInstance: e ].
	
	oldObjects addAll: oldInstances.
	newObjects addAll: newInstances.
	
]

{ #category : #compiler }
TMEnvironment >> compiler [

	^ self class compiler
		environment: self;
		yourself
]

{ #category : #accessing }
TMEnvironment >> content [
	^ content ifNil: [ content := Dictionary new ]
]

{ #category : #copying }
TMEnvironment >> copyClassNamed: aClassName [
	
	^ self copyClassNamed: aClassName withNewName: aClassName 
]

{ #category : #copying }
TMEnvironment >> copyClassNamed: aClassName withNewName: aNewname [
	
	| originalClass builder newClass |
	originalClass := self parent at: aClassName.
	
	builder := ShiftClassBuilder new
		buildEnvironment: (ShGlobalsEnvironment new environment: self; yourself);
		fillFor: originalClass;
		superclass: nil;
		superclassName: originalClass superclass name;
		name: aNewname;
		environment: self;
		yourself.
		
	builder builderEnhancer: (TMBuilderEnhancer for: self wrapping: builder builderEnhancer).	
	
	newClass := builder build.
	
	(self content includesKey: newClass superclass name)
		ifTrue: [ newClass superclass addSubclass: newClass ].	
			
	self migrateClassState: originalClass to: newClass.	
	
	self content at: aClassName put: newClass.
	^ newClass
]

{ #category : #migrating }
TMEnvironment >> copyObject: oldObject to: newClass [

	^ (TMByNameMigrationStrategy for: newClass from: oldObject class) migrateInstance: oldObject
]

{ #category : #'creating classes' }
TMEnvironment >> createSubclassOf: aClassName withNewName: aNewname slots: someSlots [
	
	^ self createSubclassOf: aClassName withNewName: aNewname slots: someSlots sharedVariables: '' package: ''
]

{ #category : #'creating classes' }
TMEnvironment >> createSubclassOf: aClassName withNewName: aNewname slots: someSlots sharedVariables: sharedVariablesString package: package [ 

	| newClass builder |
	builder := ShiftClassBuilder new
		name: aNewname;
		slots: someSlots;
		superclassName: aClassName;
		buildEnvironment: (ShGlobalsEnvironment new environment: self; yourself);
		sharedVariablesFromString: sharedVariablesString;
		environment: self;
		category: package;
		yourself.
	
	newClass := builder build.

	(self content includesKey: aNewname) 
		ifTrue: [ self migrateClass: newClass from: (self content at: aNewname) ]
		ifFalse: [ self content at: aNewname put: newClass ].

	newClass subclasses do: [ :e | self recreateClass: e ].

	^ newClass
]

{ #category : #'default classes' }
TMEnvironment >> defaultClassNames [
	^ #(ProtoObject UndefinedObject SmallInteger True False FixedLayout Exception Object)
]

{ #category : #evaluating }
TMEnvironment >> evaluate: sourceCode [
	| aMethod obj |

	aMethod := self compiler
		class: self evaluateClass;
		noPattern: true;
		source: sourceCode;
		compile.

	obj := self evaluateClass new.
	obj instVarNamed: #transaction put: (TMTransaction for: self).

	^ obj withArgs: #() executeMethod: aMethod
]

{ #category : #evaluating }
TMEnvironment >> evaluateClass [
	^ evaluateClass
		ifNil: [ evaluateClass := self
				createSubclassOf: #Object
				withNewName: #EvaluateClass
				slots: #(transaction) ]
]

{ #category : #accessing }
TMEnvironment >> globalMigrators [
	^ globalMigrators ifNil: [ globalMigrators := Dictionary new ]
]

{ #category : #'configuring-migration' }
TMEnvironment >> migrate: aClass with: aBlockClosure [

	self migrationStrategies
		at: aClass name
		put:
			(TMBlockMigrationStrategy
				for: aClass
				from: (self parent at: aClass name)
				using: aBlockClosure)
]

{ #category : #migrating }
TMEnvironment >> migrateClass: aClass from: oldClass [

	| oldObjects newObjects oldInstances newInstances |

	oldObjects := OrderedCollection new.
	newObjects := OrderedCollection new.

	(self content includesKey: aClass superclass name)
		ifTrue: [ oldClass superclass removeSubclass: oldClass.
			aClass superclass addSubclass: aClass ].

	aClass subclasses: oldClass subclasses.

	oldInstances := oldClass allInstances.
	newInstances := oldInstances collect: [ :old | self copyObject: old to: aClass ].

	self migrateClassState: oldClass to: aClass.

	oldObjects add: oldClass.
	oldObjects add: oldClass class.
	oldObjects addAll: oldInstances.
	newObjects add: aClass.
	newObjects add: aClass class.
	newObjects addAll: newInstances.

	oldObjects asArray elementsForwardIdentityTo: newObjects asArray
]

{ #category : #migrating }
TMEnvironment >> migrateClassState: oldClass to: aClass [

	TMUseOriginalGlobalMigrator new migrateClassState: oldClass to: aClass
]

{ #category : #accessing }
TMEnvironment >> migrationStrategies [
	^ migrationStrategies ifNil: [ migrationStrategies := Dictionary new ]
]

{ #category : #migrating }
TMEnvironment >> missingGlobalMigrator: aClass [ 
	self error: 'Missing global migrator for ' , aClass name
]

{ #category : #accessing }
TMEnvironment >> organization [
	^ self parent organization
]

{ #category : #accessing }
TMEnvironment >> parent [
	^ parent ifNil: [ parent := Smalltalk globals ]
]

{ #category : #'creating classes' }
TMEnvironment >> recreateClass: oldClass [

	| newClass builder |
		
	builder := ShiftClassBuilder new
		buildEnvironment: (ShGlobalsEnvironment new environment: self; yourself);
		fillFor: oldClass;
		superclass: nil;
		superclassName: oldClass superclass name;
		environment: self;
		yourself.
	
	newClass := builder build.

	self migrateClass: newClass from: oldClass.

	newClass subclasses do: [ :e | self recreateClass: e ].

	^ newClass
]

{ #category : #'commiting-rollback' }
TMEnvironment >> rollback [
	content := nil.
	migrationStrategies := nil.
	globalMigrators := nil
]

{ #category : #'configuring-migration' }
TMEnvironment >> useByNameMigrationFor: aClass [
	self migrationStrategies
		at: aClass name
		put: (TMByNameMigrationStrategy for: aClass from: (self parent at: aClass name)) 
]

{ #category : #'configuring-migration' }
TMEnvironment >> useNewStateFor: aClass [ 
	self globalMigrators at: aClass name put: TMUseNewGlobalMigrator new
]

{ #category : #'configuring-migration' }
TMEnvironment >> useOriginalStateFor: aClass [ 
	self globalMigrators at: aClass name put: TMUseOriginalGlobalMigrator new
]
