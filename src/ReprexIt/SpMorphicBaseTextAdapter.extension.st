Extension { #name : #SpMorphicBaseTextAdapter }

{ #category : #'*ReprexIt' }
SpMorphicBaseTextAdapter >> reprexInsert: aString at: positionIndex [
	| text |

	text := self getText.
	text := 
		(text copyFrom: 1 to: positionIndex), 
		aString.

	self model text: text
]
