Class {
	#name : #TransactionalEvaluatorTest,
	#superclass : #TMTestCase,
	#category : #'Transactions-Tests'
}

{ #category : #tests }
TransactionalEvaluatorTest >> testAccessingAClassUsesACopy [
	
	| aClass |
		
	aClass := env evaluate: 'TMTestClass'.
	
	self assert: aClass isNotNil.
	self assert: aClass isClass.
	self deny: aClass equals: (Smalltalk at: #TMTestClass).
]

{ #category : #tests }
TransactionalEvaluatorTest >> testExecutingCodeDoesNotAffectOriginalState [

	(Smalltalk at: #TMTestClass) globalState: 32.
	
	env evaluate: '	TMTestClass globalState: Object new.'.	
	
	self deny: (env evaluate: 'TMTestClass globalState') equals: 32.
	self assert: (env evaluate: 'TMTestClass globalState isKindOf: Object').
	
	self assert: (Smalltalk at: #TMTestClass) globalState equals: 32.
]
