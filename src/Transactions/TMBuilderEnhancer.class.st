Class {
	#name : #TMBuilderEnhancer,
	#superclass : #Object,
	#instVars : [
		'original',
		'environment'
	],
	#category : #Transactions
}

{ #category : #'instance-creation' }
TMBuilderEnhancer class >> for: aTMEnvironment wrapping: aBuilderEnhancer [ 
	^ self new
		environment: aTMEnvironment;
		original: aBuilderEnhancer;
		yourself.
]

{ #category : #'as yet unclassified' }
TMBuilderEnhancer >> afterMethodsCompiled: builder [
	original afterMethodsCompiled: builder
]

{ #category : #accessing }
TMBuilderEnhancer >> classCreated: aBuilder [
	
	environment content at: aBuilder newClass name put: aBuilder newClass.
	original classCreated: aBuilder
]

{ #category : #'as yet unclassified' }
TMBuilderEnhancer >> compileMethodsFor: aBuilder [ 
	
	original compileMethodsFor: aBuilder
]

{ #category : #'as yet unclassified' }
TMBuilderEnhancer >> configureClass: newClass superclass: superclass withLayoutType: layoutType slots: slots [
	original configureClass: newClass superclass: superclass withLayoutType: layoutType slots: slots
]

{ #category : #'as yet unclassified' }
TMBuilderEnhancer >> configureMetaclass: newMetaclass superclass: superclass withLayoutType: aLayoutType slots: classSlots [ 
	^ original configureMetaclass: newMetaclass superclass: superclass withLayoutType: aLayoutType slots: classSlots
]

{ #category : #accessing }
TMBuilderEnhancer >> environment: aTMEnvironment [ 
	environment := aTMEnvironment
]

{ #category : #'as yet unclassified' }
TMBuilderEnhancer >> initializeBuilder: aShiftClassBuilder [ 
	" I will not do nothing else, as the original enhancer have initialized the builder"
]

{ #category : #'as yet unclassified' }
TMBuilderEnhancer >> metaclassCreated: aShiftClassBuilder [ 
	
	^ original metaclassCreated: aShiftClassBuilder 
]

{ #category : #'as yet unclassified' }
TMBuilderEnhancer >> on: newClass declareClassVariables: sharedVariables sharing: sharedPoolsString [
	original on: newClass declareClassVariables: sharedVariables sharing: sharedPoolsString
]

{ #category : #accessing }
TMBuilderEnhancer >> original: aShDefaultBuilderEnhancer [ 
	original := aShDefaultBuilderEnhancer
]
