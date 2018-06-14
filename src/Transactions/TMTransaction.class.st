Class {
	#name : #TMTransaction,
	#superclass : #Object,
	#instVars : [
		'environment'
	],
	#category : #Transactions
}

{ #category : #'instance creation' }
TMTransaction class >> for: anEnvironment [

	^ self new
		environment: anEnvironment;
		yourself
]

{ #category : #operations }
TMTransaction >> commit [
	environment commit
]

{ #category : #'creating classes' }
TMTransaction >> createSubclassOf: aClassName withNewName: aNewname slots: someSlots sharedVariables: sharedVariablesString package: package [ 
	^ environment createSubclassOf: aClassName withNewName: aNewname slots: someSlots sharedVariables: sharedVariablesString package: package 

]

{ #category : #accessing }
TMTransaction >> environment: aTMEnvironment [ 
	environment := aTMEnvironment
]

{ #category : #'configuring-migration' }
TMTransaction >> migrate: aClass with: aMigrationBlock [
	environment migrate: aClass with: aMigrationBlock
]

{ #category : #operations }
TMTransaction >> rollback [
	environment rollback
]

{ #category : #operations }
TMTransaction >> useByNameMigrationFor: aClass [ 
	environment useByNameMigrationFor: aClass
]

{ #category : #'configuring-migration' }
TMTransaction >> useNewStateFor: aClass [ 
	environment useNewStateFor: aClass 

]

{ #category : #'configuring-migration' }
TMTransaction >> useOriginalStateFor: aClass [ 
	environment useOriginalStateFor: aClass 
]
