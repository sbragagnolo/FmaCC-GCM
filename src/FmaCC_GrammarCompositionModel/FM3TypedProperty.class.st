Class {
	#name : #FM3TypedProperty,
	#superclass : #FM3Property,
	#instVars : [
		'propertyType',
		'propertyTypes'
	],
	#category : #'FmaCC_GrammarCompositionModel-FM3Extension'
}

{ #category : #meta }
FM3TypedProperty class >> annotation [
	<FMClass: #TypedProperty super: #FM3Element>
	<package: #FM3>

]

{ #category : #accessing }
FM3TypedProperty >> addPropertyType: anFMClass [

	self propertyTypes add: anFMClass
]

{ #category : #accessing }
FM3TypedProperty >> addPropertyTypes: aCollection [

	self propertyTypes addAll: aCollection
]

{ #category : #accessing }
FM3TypedProperty >> propertyTypes [
"	<FMProperty: #propertyType type: #FM3Class>"
	"The type of this property should be FM3Primitive or something else, but it's currently impossible to reference abstract classes"
	^ propertyTypes ifNil: [ propertyTypes := Set new  ]
]
