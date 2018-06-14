Class {
	#name : #TransactionalCommitTest,
	#superclass : #TMTestCase,
	#category : #'Transactions-Tests'
}

{ #category : #tests }
TransactionalCommitTest >> testCommitChangesInClassStructureWithDefaultMigration [

	| inst1 inst2 | 

	env evaluate: '	
		transaction createSubclassOf: #Object withNewName: #TMTestClass 
			slots: #(anInstanceVariable anotherInstanceVariable aThirdSlot)
			sharedVariables: ''ASharedVariable''
			package: ''Transactions-Tests'''.
			
	env evaluate: 'transaction useByNameMigrationFor: TMTestClass'.

	inst1 := (Smalltalk at: #TMTestClass) new.
	inst1 instVarNamed: #anInstanceVariable put: 1.
	inst1 instVarNamed: #anotherInstanceVariable put: 2.
		
	self assert: (env evaluate: 'TMTestClass slots size') equals: 3.
	self assert: (Smalltalk at: #TMTestClass) slots size equals: 2.

	env evaluate: '	transaction commit'.
	self assert: (Smalltalk at: #TMTestClass) slots size equals: 3.

	self assert: (inst1 instVarNamed: #anInstanceVariable) equals: 1.
	self assert: (inst1 instVarNamed: #anotherInstanceVariable) equals: 2.	
	self assert: (inst1 instVarNamed: #aThirdSlot) equals: nil.		
]

{ #category : #tests }
TransactionalCommitTest >> testCommitChangesInClassStructureWithMigrating [

	| inst1 | 

	env evaluate: '	
		transaction createSubclassOf: #Object withNewName: #TMTestClass 
			slots: #(anInstanceVariable anotherInstanceVariable aThirdSlot)
			sharedVariables: ''ASharedVariable''
			package: ''Transactions-Tests'''.
			
	env evaluate: 'transaction migrate: TMTestClass with: 
		[:m :old :new | 
			m copyExistingSlotsFrom: old to: new.
			new instVarNamed: #aThirdSlot put: 3 ]'.

	inst1 := (Smalltalk at: #TMTestClass) new.
	inst1 instVarNamed: #anInstanceVariable put: 1.
	inst1 instVarNamed: #anotherInstanceVariable put: 2.
		
	self assert: (env evaluate: 'TMTestClass slots size') equals: 3.
	self assert: (Smalltalk at: #TMTestClass) slots size equals: 2.

	env evaluate: '	transaction commit'.
	self assert: (Smalltalk at: #TMTestClass) slots size equals: 3.

	self assert: (inst1 instVarNamed: #anInstanceVariable) equals: 1.
	self assert: (inst1 instVarNamed: #anotherInstanceVariable) equals: 2.	
	self assert: (inst1 instVarNamed: #aThirdSlot) equals: 3.		
]

{ #category : #tests }
TransactionalCommitTest >> testCommitChangesInClassStructureWithoutMigratingRaiseError [

	| inst1 | 

	env evaluate: '	
		transaction createSubclassOf: #Object withNewName: #TMTestClass 
			slots: #(anInstanceVariable anotherInstanceVariable aThirdSlot)
			sharedVariables: ''ASharedVariable''
			package: ''Transactions-Tests'''.

	inst1 := (Smalltalk at: #TMTestClass) new.
	inst1 instVarNamed: #anInstanceVariable put: 1.
	inst1 instVarNamed: #anotherInstanceVariable put: 2.
		
	self should: [env evaluate: '	transaction commit'] raise: Error.

]

{ #category : #tests }
TransactionalCommitTest >> testCommitChangesInClassWithoutInstances [

	env evaluate: '	
		transaction createSubclassOf: #Object withNewName: #TMTestClass 
			slots: #(anInstanceVariable anotherInstanceVariable thirdSlot)
			sharedVariables: ''ASharedVariable''
			package: ''Transactions-Tests'''.
			
	self assert: (env evaluate: 'TMTestClass slots size') equals: 3.
	self assert: (Smalltalk at: #TMTestClass) slots size equals: 2.

	env evaluate: '	transaction commit'.
	self assert: (Smalltalk at: #TMTestClass) slots size equals: 3.


]

{ #category : #tests }
TransactionalCommitTest >> testCommitChangesInClassWithoutStructChange [

	| inst1 inst2 | 

	env evaluate: '	
		transaction createSubclassOf: #Object withNewName: #TMTestClass 
			slots: #(anInstanceVariable anotherInstanceVariable)
			sharedVariables: ''ASharedVariable''
			package: ''Transactions-Tests'''.

	env evaluate: 'TMTestClass compile: ''anInstanceVariable ^ anInstanceVariable'''.

	inst1 := (Smalltalk at: #TMTestClass) new.
	inst1 instVarNamed: #anInstanceVariable put: 1.
	inst1 instVarNamed: #anotherInstanceVariable put: 2.

	inst2 := (Smalltalk at: #TMTestClass) new.
	inst2 instVarNamed: #anInstanceVariable put: 3.
	inst2 instVarNamed: #anotherInstanceVariable put: 4.
		
	env evaluate: '	transaction commit'.

	self assert: inst1 anInstanceVariable equals: 1.
	self assert: inst2 anInstanceVariable equals: 3.
	self shouldnt: [ (Smalltalk at: #TMTestClass) >> #anInstanceVariable ] raise: Error.


]

{ #category : #tests }
TransactionalCommitTest >> testCommitChangesInGlobalStateWithCopyingState [

	(Smalltalk at: #TMTestClass) globalState: 32.

	env 
		evaluate: '	TMTestClass globalState: 42.
						transaction useOriginalStateFor: TMTestClass.
						transaction commit'.

	self assert: (Smalltalk at: #TMTestClass) globalState equals: 32.
]

{ #category : #tests }
TransactionalCommitTest >> testCommitChangesInGlobalStateWithCopyingStateUsingTransactionState [

	(Smalltalk at: #TMTestClass) globalState: 32.

	env 
		evaluate: '	TMTestClass globalState: 42.
						transaction useNewStateFor: TMTestClass.
						transaction commit'.

	self assert: (Smalltalk at: #TMTestClass) globalState equals: 42.
]

{ #category : #tests }
TransactionalCommitTest >> testCommitChangesInGlobalStateWithoutMigrationRaiseError [

	(Smalltalk at: #TMTestClass) globalState: 32.

	env evaluate: '	TMTestClass globalState: 42.'.	
	self should: [env evaluate: 'transaction commit'] raise: Error.

	self assert: (Smalltalk at: #TMTestClass) globalState equals: 32.
]

{ #category : #tests }
TransactionalCommitTest >> testCommitWithoutChangesInGlobalStateWithoutMigration [

	(Smalltalk at: #TMTestClass) globalState: 32.

	env evaluate: '	TMTestClass globalState: 32.'.	
	env evaluate: 'transaction commit'.

	self assert: (Smalltalk at: #TMTestClass) globalState equals: 32.
]
