Class {
	#name : #ReprexItTest,
	#superclass : #TestCase,
	#instVars : [
		'reprextItEval'
	],
	#category : #'ReprexIt-Tests'
}

{ #category : #accessing }
ReprexItTest >> contextFor: aString [ 

	^ SpCodePresenter new
		withoutSyntaxHighlight;
		beNotEditable;
		text: aString;
		yourself
]

{ #category : #accessing }
ReprexItTest >> reprextItEval [

	^ reprextItEval
]

{ #category : #accessing }
ReprexItTest >> reprextItEval: anObject [

	reprextItEval := anObject
]

{ #category : #running }
ReprexItTest >> setUp [

	super setUp.
	reprextItEval := SpCodeReprexItCommand new.	
	"Put here a common initialization logic for tests"
]

{ #category : #tests }
ReprexItTest >> testMultipleVariables [

	| script expected |
	
	script := '| myObj anObj |
myObj := 1.
anObj := 2.
myObj := 5 + anObj.'.

	expected := '```smalltalk
myObj := 1
"1"
anObj := 2
"2"
^ myObj := 5 + anObj
"7"
```'.

	reprextItEval context: (self contextFor: script).
	reprextItEval context selectionInterval: (1 to: script size).
	self assert: reprextItEval reprexIt trimmed equals: expected trimmed.
]
