Class {
	#name : #TMTestCase,
	#superclass : #TestCase,
	#instVars : [
		'createdClasses',
		'env'
	],
	#category : #'Transactions-Tests'
}

{ #category : #'as yet unclassified' }
TMTestCase >> createRealClass: aBlock [
	| newClass |
	newClass := aBlock value.
	createdClasses add: newClass.
	^ newClass
]

{ #category : #initialization }
TMTestCase >> initialize [
	
	createdClasses := OrderedCollection new
]

{ #category : #running }
TMTestCase >> setUp [

	| testClass |
	super setUp.
	
	testClass := self createRealClass: [ 
		Object subclass: #TMTestClass
		instanceVariableNames: 'anInstanceVariable anotherInstanceVariable'
		classVariableNames: 'ASharedVariable'
		package: 'Transactions-Tests' ].
	
	testClass compile: 'anotherClass
	^ TMTestClass2 '.
	
	testClass class compile: 'globalState: aValue
	ASharedVariable := aValue'.

	testClass class compile: 'globalState
	^ASharedVariable'.
	
	self createRealClass: [ 
		testClass subclass: #TMTestSubClass
		instanceVariableNames: ''
		classVariableNames: ''
		package: 'Transactions-Tests'].
	
	self createRealClass: [  
		Object subclass: #TMTestClass2
		instanceVariableNames: ''
		classVariableNames: ''
		package: 'Transactions-Tests'].
	
	env := TMEnvironment new.
]

{ #category : #running }
TMTestCase >> tearDown [

	createdClasses do: #removeFromSystem.
	env := nil.
	
	super tearDown
]
