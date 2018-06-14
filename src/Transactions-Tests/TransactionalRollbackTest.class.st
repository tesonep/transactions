Class {
	#name : #TransactionalRollbackTest,
	#superclass : #TMTestCase,
	#category : #'Transactions-Tests'
}

{ #category : #tests }
TransactionalRollbackTest >> testRollback [

	env evaluate: '	
		transaction createSubclassOf: #Object withNewName: #TMTestClass 
			slots: #(anInstanceVariable anotherInstanceVariable thirdSlot)
			sharedVariables: ''ASharedVariable''
			package: ''Transactions-Tests'''.
			
	self assert: (env evaluate: 'TMTestClass slots size') equals: 3.
	
	env evaluate: 'transaction rollback'.

	self assert: (env evaluate: 'TMTestClass slots size') equals: 2.

]

{ #category : #tests }
TransactionalRollbackTest >> testRollbackEmpty [

	env evaluate: 'transaction rollback'.
]

{ #category : #tests }
TransactionalRollbackTest >> testRollbackOfGlobalState [

	(Smalltalk at: #TMTestClass) globalState: 32.
	
	env evaluate: '	TMTestClass globalState: Object new.'.		
	self assert: (env evaluate: 'TMTestClass globalState isKindOf: Object').
	
	env evaluate: 'transaction rollback'.
	
	self assert: (env evaluate: 'TMTestClass globalState') equals: 32.
]
