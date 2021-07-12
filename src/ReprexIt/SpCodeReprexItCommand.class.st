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
SpCodeReprexItCommand >> evaluate: aText andDo: aBlock [
	"Treat the current selection as an expression; evaluate it and invoke aBlock with the result."
	
	^ String streamContents: [ : stream |
		aText asString linesDo: [ : line | 
			stream << (self reprex: line andDo: aBlock) contents ] ]
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
SpCodeReprexItCommand >> reprex: aString andDo: aBlock [
	"Treat the current selection as an expression; evaluate it and invoke aBlock with the result and evaluated expression ."

	| stream result receiver evaluationContext |
	
	stream := aString readStream.
	receiver := self context doItReceiver.
	evaluationContext := self context doItContext.
	result := receiver class compiler
		source: stream;
		context: evaluationContext;
		receiver: receiver;
		requestor: receiver;
		failBlock:  [ ^ nil ];
		evaluate.		
	^ aBlock value: aString value: result.

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
