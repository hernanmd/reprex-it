Extension { #name : #SpAbstractTextPresenter }

{ #category : #'*ReprexIt' }
SpAbstractTextPresenter >> reprexInsert: aString at: positionIndex [
	"inserts aString into the text string. 
	 positionIndex indicates the position index (as in #indexOf) the insertion."
	
	self withAdapterDo: [ :anAdapter |
		anAdapter reprexInsert: aString at: positionIndex ]
]
