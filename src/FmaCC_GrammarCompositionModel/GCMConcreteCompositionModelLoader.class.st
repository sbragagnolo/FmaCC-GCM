Class {
	#name : #GCMConcreteCompositionModelLoader,
	#superclass : #Object,
	#instVars : [
		'model',
		'virtualLoader',
		'parser',
		'virtualModelLoader',
		'map'
	],
	#category : #'FmaCC_GrammarCompositionModel-ModelLoader'
}

{ #category : #adding }
GCMConcreteCompositionModelLoader >> addPropertyBasedOn: aFM3TypedProperty into: from [

	from ifNil: [ ^ self ].
	(aFM3TypedProperty propertyTypes flatCollect: [ :a | 
		 self allMappedClassesAndSubclasses: a ]) do: [ :to | 
		(from properties
			 detect: [ :p | p name = aFM3TypedProperty name ]
			 ifNone: [ 
				 | prop |
				 prop := FM3TypedProperty new
					         name: aFM3TypedProperty name;
					         type: from;
					         yourself.
				 from properties add: prop.
				 prop ]) addPropertyType: to ]
]

{ #category : #'as yet unclassified' }
GCMConcreteCompositionModelLoader >> allMappedClassesAndSubclasses: aFM3Class [

	^ model elements
		  detect: [ :a | 
			  a isFM3Class and: [ a name = (self classNameFor: aFM3Class name) ] ]
		  ifFound: [ :a | { a } ]
		  ifNone: [ 
			  aFM3Class subclasses flatCollect: [ :s | 
				  self allMappedClassesAndSubclasses: s ] ]
]

{ #category : #'compiling-names' }
GCMConcreteCompositionModelLoader >> classNameFor: aString [

	| n |
	n := '' join: (('_' split: aString) collect: #capitalized).
	^ (virtualModelLoader prefix , n , virtualModelLoader suffix)
		  asSymbol
]

{ #category : #'as yet unclassified' }
GCMConcreteCompositionModelLoader >> findFirstMappedSuperClass: aFM3Class [

	| current before befo |
	current := aFM3Class.


	[ 
	current isNotNil and: [ 
		model elements contains: [ :a | 
			a isFM3Class and: [ a name = (self classNameFor: aFM3Class name) ] ] ] ] 
		whileFalse: [ 
			current := current superclass.
			current isNil ifTrue: [ ^ nil ] ].
	^ model elements detect: [ :a | 
		  a isFM3Class and: [ a name = (self classNameFor: aFM3Class name) ] ]
]

{ #category : #'as yet unclassified' }
GCMConcreteCompositionModelLoader >> fixSuperClassFor: aFM3Class [

	| scn |
	scn := (self class environment at: aFM3Class name) superclass name.

	aFM3Class superclass: (model elements
			 detect: [ :e | 
				 e name
				 = (self class environment at: aFM3Class name) superclass name ]
			 ifNone: [ self registerClassNamed: scn ])
]

{ #category : #accessing }
GCMConcreteCompositionModelLoader >> initialize [

	super initialize.
	map := Dictionary new
]

{ #category : #'as yet unclassified' }
GCMConcreteCompositionModelLoader >> loadConcreteModel [

	self loadVirtualModel.
	model := FMMetaModel new
		         metamodel: FMMetaMetaModel default;
		         yourself.

	virtualModelLoader model accept: self
]

{ #category : #'as yet unclassified' }
GCMConcreteCompositionModelLoader >> loadVirtualModel [

	^ virtualModelLoader ifNil: [ 
		  virtualModelLoader := GCMVirtualCompositionModelLoader new
			                        parserClass: parser;
			                        loadTypingDefinition;
			                        yourself ]
]

{ #category : #accessing }
GCMConcreteCompositionModelLoader >> model [
	^ model
]

{ #category : #accessing }
GCMConcreteCompositionModelLoader >> parserClass: aClass [ 
	parser := aClass. 
]

{ #category : #visiting }
GCMConcreteCompositionModelLoader >> registerClassNamed: aName [

	| clzzname clzz |
	clzzname := aName.
	self assert: (self class environment at: clzzname) isNotNil.
	clzz := FM3Class new
		        name: clzzname;
		        yourself.
	model add: clzz.
	^ clzz
]

{ #category : #visiting }
GCMConcreteCompositionModelLoader >> registerProgramNode [

	self registerClassNamed: (self classNameFor: #Program)
]

{ #category : #visiting }
GCMConcreteCompositionModelLoader >> visitClass: aFM3Class [

	| clzz clzzname |
	clzzname := self classNameFor: aFM3Class name.

	model elementNamed: clzzname ifAbsent: [ 
		self class environment at: clzzname ifPresent: [ 
			clzz := FM3Class new
				        name: clzzname;
				        yourself.
			model add: clzz.
			map at: aFM3Class put: clzz.
			^ clzz ] ]
]

{ #category : #visiting }
GCMConcreteCompositionModelLoader >> visitCollection: aCollection [

	^ aCollection collect: [ :a | a accept: self ]
]

{ #category : #visiting }
GCMConcreteCompositionModelLoader >> visitModel: aFMMetaModel [

	self registerProgramNode.
	self visitCollection:
		(aFMMetaModel elements select: [ :a | a isFM3Class ]).
	model elements do: [ :a | self fixSuperClassFor: a ].
	self visitCollection:
		(aFMMetaModel elements reject: [ :a | a isFM3Class ])
]

{ #category : #visiting }
GCMConcreteCompositionModelLoader >> visitProperty: aFM3TypedProperty [

	aFM3TypedProperty type ifNil: [ ^ self halt ].

	model elements
		detect: [ :a | 
			a isFM3Class and: [ 
				a name = (self classNameFor: aFM3TypedProperty type name) ] ]
		ifFound: [ :from | 
		self addPropertyBasedOn: aFM3TypedProperty into: from ]
		ifNone: [ 
			self
				addPropertyBasedOn: aFM3TypedProperty
				into: (self findFirstMappedSuperClass: aFM3TypedProperty type) ]
]
