Class {
	#name : #FM3TypeCompositionProperty,
	#superclass : #FM3Property,
	#instVars : [
		'propertyType',
		'propertyTypes'
	],
	#category : #'FmaCC_GrammarCompositionModel-FM3Extension'
}

{ #category : #meta }
FM3TypeCompositionProperty class >> annotation [
	<FMClass: #TypeCompositionProperty super: #FM3Element>
	<package: #FM3>

]

{ #category : #adding }
FM3TypeCompositionProperty >> addPropertyType: anFMClass [

	self propertyTypes add: anFMClass
]

{ #category : #adding }
FM3TypeCompositionProperty >> addPropertyTypes: aCollection [

	self propertyTypes addAll: aCollection
]

{ #category : #adding }
FM3TypeCompositionProperty >> initialize [ 
	super initialize .
	self name: '$TypeWithTypeComposition'
]

{ #category : #adding }
FM3TypeCompositionProperty >> propertyTypes [
"	<FMProperty: #propertyType type: #FM3Class>"
	"The type of this property should be FM3Primitive or something else, but it's currently impossible to reference abstract classes"
	^ propertyTypes ifNil: [ propertyTypes := Set new  ]
]
