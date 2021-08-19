Extension { #name : #SpMorphicBaseTextAdapter }

{ #category : #'*ReprexIt' }
SpMorphicBaseTextAdapter >> reprexInsert: aString at: positionIndex [
	| text |

	text := self getText.
	text := String streamContents: [ : stream | 
		stream
			<< (text copyFrom: 1 to: positionIndex - 1);
			cr;
			<< 	aString ].

	self model text: text
]
