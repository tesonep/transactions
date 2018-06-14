Class {
	#name : #TransactionalModificationsTest,
	#superclass : #TMTestCase,
	#category : #'Transactions-Tests'
}

{ #category : #tests }
TransactionalModificationsTest >> testAskingNormalClassReturnsACopy [

	| newClass |
	newClass := env at: #TMTestClass.

	self deny: newClass equals: (Smalltalk at: #TMTestClass).
	self assert: newClass isNotNil.
]

{ #category : #tests }
TransactionalModificationsTest >> testAskingObjectReturnsSystem [

	self assert: (env at: #Object) equals: Object
]

{ #category : #tests }
TransactionalModificationsTest >> testBindingOfHerselfReturnsCopy [

	| newClass |
	newClass := env at: #TMTestClass.

	self assert: (newClass bindingOf: #TMTestClass) value equals: newClass.
]

{ #category : #tests }
TransactionalModificationsTest >> testClassIsReshaped [

	| newClass |

	newClass := env at: #TMTestClass.

	self assert: newClass slots size equals: 2.
	
	env createSubclassOf: #Object withNewName: #TMTestClass 
		slots: #(anInstanceVariable anotherInstanceVariable thirdSlot)
		sharedVariables: 'ASharedVariable'
		package: 'Transactions-Tests'.
	
	self assert: newClass slots size equals: 3.	
]

{ #category : #tests }
TransactionalModificationsTest >> testClassIsReshapedAndInstancesMigrated [

	| newClass inst |

	newClass := env at: #TMTestClass.
	inst := newClass new.
	inst instVarNamed: #anInstanceVariable put: 1.
	inst instVarNamed: #anotherInstanceVariable put: 2.

	self assert: newClass slots size equals: 2.
	
	env createSubclassOf: #Object withNewName: #TMTestClass 
		slots: #(anInstanceVariable anotherInstanceVariable thirdSlot)
		sharedVariables: 'ASharedVariable'
		package: 'Transactions-Tests'.
	
	self assert: newClass slots size equals: 3.	
	
	self assert: (inst instVarNamed: #anInstanceVariable) equals: 1.
	self assert: (inst instVarNamed: #anotherInstanceVariable) equals: 2.	
	self assert: (inst instVarNamed: #thirdSlot) equals: nil.		
]

{ #category : #tests }
TransactionalModificationsTest >> testMethodUsingOtherClassReturnsCopy [

	| newClass |
	newClass := env at: #TMTestClass.
	
	self assert: newClass new anotherClass isNotNil.
	self deny: newClass new anotherClass equals: (Smalltalk at: #TMTestClass2) 
]

{ #category : #tests }
TransactionalModificationsTest >> testSubClassHasCopiedSuperclass [

	| newClass inst |
	newClass := env at: #TMTestSubClass.
	
	inst := newClass new.
	inst instVarNamed: #anInstanceVariable put: 1.
	inst instVarNamed: #anotherInstanceVariable put: 2.

	env createSubclassOf: #Object withNewName: #TMTestClass 
		slots: #(anInstanceVariable anotherInstanceVariable thirdSlot)
		sharedVariables: 'ASharedVariable'
		package: 'Transactions-Tests'.
	
	self assert: newClass allSlots size equals: 3.	
	
	self assert: (inst instVarNamed: #anInstanceVariable) equals: 1.
	self assert: (inst instVarNamed: #anotherInstanceVariable) equals: 2.	
	self assert: (inst instVarNamed: #thirdSlot) equals: nil.		
]
