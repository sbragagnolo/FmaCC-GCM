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

	| fromClass slotName prop |
	from ifNil: [ ^ self ].
	fromClass := self class environment at: from name.
	slotName := fromClass allSlots
		            detect: [ :s | 
			            s name = aFM3TypedProperty name or: [ 
				            s name
				            =
				            (SmaCCVariableDefinition pluralNameFor:
					             aFM3TypedProperty name) ] ]
		            ifNone: [ ^ self ].

	(from allProperties contains: [ :p | p name = slotName name ]) 
		ifTrue: [ ^ self ].
	prop := from allProperties
		        detect: [ :p | p name = slotName name ]
		        ifNone: [ 
			        prop := FM3TypedProperty new
				                name: slotName name;
				                type: from;
				                yourself.
			        from properties add: prop ].

	(aFM3TypedProperty propertyTypes flatCollect: [ :a | 
		 self allMappedClassesAndSubclasses: a ]) do: [ :t | 
		(prop propertyTypes includes: t) ifFalse: [ prop addPropertyType: t ] ]
]

{ #category : #'as yet unclassified' }
GCMConcreteCompositionModelLoader >> allMappedClassesAndSubclasses: aFM3Class [

	| thisClass mySubClasses |
	thisClass := model elements
		             detect: [ :a | 
			             a isFM3Class and: [ 
				             a name = (self classNameFor: aFM3Class name) ] ]
		             ifFound: [ :a | { a } ]
		             ifNone: [ {  } ].

	mySubClasses := aFM3Class subclasses flatCollect: [ :s | 
		                self allMappedClassesAndSubclasses: s ].
	^ thisClass , mySubClasses
]

{ #category : #'as yet unclassified' }
GCMConcreteCompositionModelLoader >> allMappedClassesAndSuperclasses: aFM3Class [

	| first mySuperClasses current |
	first := self findFirstMappedSuperClass: aFM3Class.

	mySuperClasses := OrderedCollection new.
	current := first.
	[ current isNotNil ] whileTrue: [ 
		mySuperClasses add: current.
		current := current superclass ].
	^ mySuperClasses reverse
]

{ #category : #asserting }
GCMConcreteCompositionModelLoader >> assertVariablesMakeSense: aFM3Class [

	| clzz slotNames |
	
	clzz := self class environment at: aFM3Class name.
	slotNames := clzz slots collect: #name.
	"
	self assert:
		(aFM3Class properties allSatisfy: [ :n | slotNames includes: n name ])"
]

{ #category : #'compiling-names' }
GCMConcreteCompositionModelLoader >> classNameFor: aString [

	| n |
	aString = #SmaCCToken ifTrue: [ ^ aString ].

	n := '' join: (('_' split: aString) collect: #capitalized).
	^ (virtualModelLoader prefix , n , virtualModelLoader suffix)
		  asSymbol
]

{ #category : #'as yet unclassified' }
GCMConcreteCompositionModelLoader >> findFirstMappedSuperClass: aFM3Class [

	| current |
	current := aFM3Class.


	[ 
	current isNotNil and: [ 
		model elements contains: [ :a | 
			a isFM3Class and: [ a name = (self classNameFor: aFM3Class name) ] ] ] ] 
		whileFalse: [ 
			current isNil ifTrue: [ ^ nil ].
			current := current superclass.
			current isNil ifTrue: [ ^ nil ]
			 ].
	^ model elements detect: [ :a | 
		  a isFM3Class and: [ a name = (self classNameFor: aFM3Class name) ] ]
]

{ #category : #'as yet unclassified' }
GCMConcreteCompositionModelLoader >> firstMappedClassOrSuperClass: aFMClass [

	| current mapped |
	current := aFMClass.
	[ 
	current isNotNil and: [ 
		mapped := model elements
			          detect: [ :a | 
				          a isFM3Class and: [ 
					          a name = (self classNameFor: current name) ] ]
			          ifNone: [ nil ].
		mapped isNil ] ] whileTrue: [ current := aFMClass superclass ].
	^ mapped
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

	virtualModelLoader model accept: self.
	model elements
		select: [ :a | a isFM3Class ]
		thenDo: [ :c | self assertVariablesMakeSense: c ]
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
GCMConcreteCompositionModelLoader >> registerSmaccTokenNode [

	self registerClassNamed: #SmaCCToken
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
	self registerSmaccTokenNode.
	self visitCollection:
		(aFMMetaModel elements select: [ :a | a isFM3Class ]).
	model elements do: [ :a | self fixSuperClassFor: a ].
	self visitCollection:
		(aFMMetaModel elements reject: [ :a | a isFM3Class ])
]

{ #category : #visiting }
GCMConcreteCompositionModelLoader >> visitProperty: aFM3TypedProperty [

	(self allMappedClassesAndSuperclasses: aFM3TypedProperty type) do: [ 
		:from | self addPropertyBasedOn: aFM3TypedProperty into: from ]
]
