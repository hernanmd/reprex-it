Class {
	#name : #BaselineOfReprexIt,
	#superclass : #BaselineOf,
	#category : #BaselineOfReprexIt
}

{ #category : #baselines }
BaselineOfReprexIt >> baseline: spec [
  <baseline>
	spec
		for: #(common)
		do: [ 
			spec 
				package: 'ReprexIt';
				package: 'ReprexIt-Tests'	with: [ spec requires: #(ReprexIt) ].
			spec 
				group: 'Core' 						with: #('ReprexIt');
				group: 'Tests' 						with: #('ReprexIt' 'ReprexIt-Tests');
				group: 'default' 					with: #('Core' 'Tests') ]
]
