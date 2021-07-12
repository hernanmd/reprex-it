Class {
	#name : #SpCodeReprexItCommand,
	#superclass : #SpCodeSelectionCommand,
	#category : #'ReprexIt-Commands-Code'
}

{ #category : #defaults }
SpCodeReprexItCommand class >> defaultIconName [
	^#smallProfile 
]

{ #category : #default }
SpCodeReprexItCommand class >> defaultName [

	^ 'Reprex it'
]

{ #category : #defaults }
SpCodeReprexItCommand class >> defaultShortcutKey [

	^ $r shift command mac 
		| $r shift control win
		| $r shift control unix
]

{ #category : #execution }
SpCodeReprexItCommand >> afterSelectionInsertAndSelect: aString [
	| selection |
	selection := self context selectionInterval.
	self context reprexInsert: aString at: selection last + 1.
	self context
		selectionInterval: (selection last + 1 to: selection last + aString size)
]

{ #category : #execution }
SpCodeReprexItCommand >> buildCompiledMethod: aText [

	| codeStream doItReceiver doItContext aCompiledMethod |
	codeStream := aText readStream.
	(self context respondsTo: #doItReceiver)
		ifTrue: [ 
			doItReceiver := self context doItReceiver.
			doItContext := self context doItContext ]
		ifFalse: [ 
			doItReceiver := doItContext := nil ].
		
	aCompiledMethod := self compile: codeStream for: doItReceiver in: doItContext.
	aCompiledMethod isReturnSpecial ifTrue: [ 
		self inform: 'Nothing to debug, the expression is optimized' ].
	^ aCompiledMethod.
]

{ #category : #compiling }
SpCodeReprexItCommand >> compile: aStream for: anObject in: evalContext [
	| methodClass |

	methodClass := evalContext
		ifNil: [ anObject class ]
		ifNotNil: [ evalContext methodClass ].

	^ context class compiler
		source: aStream;
		class: methodClass;
		context: evalContext;
		requestor: context; "it should enable a visibility of current tool variables in new debugger"
		noPattern: true;
		failBlock: [ ^ nil ];
		compile
]

{ #category : #private }
SpCodeReprexItCommand >> evaluate: aText andDo: aBlock [
	"Treat the current selection as an expression; evaluate it and invoke aBlock with the result."
	
	| stmts aCompiledMethod |

	(aCompiledMethod := self buildCompiledMethod: aText)
		ifNil: [ ^ self ].
	stmts := aCompiledMethod ast statements.
	"process := [ aCompiledMethod ast statements ] newProcess.	"
	"session := process newDebugSessionNamed: 'ReprexIt Session' startedAt: process suspendedContext."

	^ String streamContents: [ : stream |
		 stmts do: [ : rbStmt | 
			stream << (self reprex: rbStmt andDo: aBlock) contents ] ].
]

{ #category : #execution }
SpCodeReprexItCommand >> execute [
	"Treat the current text selection as an expression; evaluate it. Insert the 
	description of the result of evaluation after the selection and then make 
	this description the new text selection."
	
	self afterSelectionInsertAndSelect: self reprexIt
	

]

{ #category : #execution }
SpCodeReprexItCommand >> printExpression: evalString withResult: aResult [
	" Answer a <String> with the expression in evalString and aResult, separated by a new line "

	^ String streamContents: [ : stream | 
		stream 
			<< evalString; cr;
			<< (aResult asString surroundedBy: '"') ; 
			cr ]

]

{ #category : #execution }
SpCodeReprexItCommand >> reprex: aRBNode andDo: aBlock [
	"Treat the current selection as an expression; evaluate it and invoke aBlock with the result and evaluated expression ."

	| sourceCode result |
	
	sourceCode := aRBNode formattedCode.
	result := aRBNode isReturn
		ifFalse: [ aRBNode evaluate ]
		ifTrue: [ aRBNode children first evaluate ].
	^ aBlock value: sourceCode value: result.

]

{ #category : #execution }
SpCodeReprexItCommand >> reprexIt [
	" Answer a <String> useful as a reproducible example expression, with results inlined "

	^ String streamContents: [ :stream |
		stream 
			cr;
			<< '```smalltalk'; 
			cr.
		(self toReprexString: stream).
		stream << '```' ]
]

{ #category : #execution }
SpCodeReprexItCommand >> toReprexString: aStream [
	" Evaluate the user selection and append expressions and results on aStream "

	self evaluateSelectionAndDo: [ : line : result | 
		aStream << (self printExpression: line withResult: result) ].

]
