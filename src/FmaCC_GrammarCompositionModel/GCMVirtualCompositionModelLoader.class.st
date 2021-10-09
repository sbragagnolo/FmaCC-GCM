Class {
	#name : #GCMVirtualCompositionModelLoader,
	#superclass : #Object,
	#instVars : [
		'model',
		'parserClass',
		'parser',
		'ast',
		'astModelPrefix',
		'astModelSuffix',
		'astModelRoot',
		'astModelStart',
		'stack'
	],
	#category : #'FmaCC_GrammarCompositionModel-ModelLoader'
}

{ #category : #visiting }
GCMVirtualCompositionModelLoader >> acceptNode: aSmaCCParseNode [
	aSmaCCParseNode isNil
		ifTrue: [ ^ nil ].
	^ aSmaCCParseNode acceptVisitor: self
]

{ #category : #'as yet unclassified' }
GCMVirtualCompositionModelLoader >> closerParentNameTo: aSmaCCProductionSymbolNode [

	^ aSmaCCProductionSymbolNode parent acceptVisitor:
		  GCMParentNameGatherer new
]

{ #category : #'as yet unclassified' }
GCMVirtualCompositionModelLoader >> computeCompositionModel [
	self shouldBeImplemented.
]

{ #category : #visiting }
GCMVirtualCompositionModelLoader >> fm3ClassNamed: aNameToken [

	| element |
	^ model elementNamed: aNameToken capitalized  ifAbsent: [ 
		  element := FM3Class new
			             name: aNameToken capitalized;
			             yourself.
		  model add: element.
		  element ]
]

{ #category : #initialization }
GCMVirtualCompositionModelLoader >> initialize [

	super initialize.
	model := FMMetaModel new
		         metamodel: FMMetaMetaModel default;
		         yourself.
	stack := Stack new. 
	
]

{ #category : #'as yet unclassified' }
GCMVirtualCompositionModelLoader >> loadInformationFrom: aNewVersionOfProperty into: aBuildingProperty [

	self assert: aNewVersionOfProperty name = aBuildingProperty name.
	aBuildingProperty addPropertyTypes: aNewVersionOfProperty propertyTypes.

	aNewVersionOfProperty isMultivalued ifTrue: [ 
		aBuildingProperty isMultivalued: true ].
	
]

{ #category : #initialization }
GCMVirtualCompositionModelLoader >> loadTypingDefinition [

	parser := SmaCCDefinitionParser on:
		          (ReadStream on: parserClass parserDefinitionString).
	parser scanner parseSourceSelector: #canParseSmalltalk:.
	ast := parser parse.
	ast acceptVisitor: self
	
]

{ #category : #accessing }
GCMVirtualCompositionModelLoader >> model [
	^ model
]

{ #category : #initialization }
GCMVirtualCompositionModelLoader >> parserClass: aParserClass [

	parserClass := aParserClass
]

{ #category : #accessing }
GCMVirtualCompositionModelLoader >> prefix [

	^ astModelPrefix
]

{ #category : #initialization }
GCMVirtualCompositionModelLoader >> set: superClass asSuperclassWithoutLoopingOf: vartype [

	| current |
	current := superClass.
	[ current isNotNil and: [ current ~= vartype ] ] whileTrue: [ 
		current := current superclass ].
	current
		ifNil: [ 
		vartype = superClass ifFalse: [ vartype superclass: superClass ] ]
		ifNotNil: [  ]
]

{ #category : #generated }
GCMVirtualCompositionModelLoader >> suffix [
	^ astModelSuffix 
]

{ #category : #visiting }
GCMVirtualCompositionModelLoader >> visitAssociativeDirective: aSmaCCAssociativeDirectiveNode [ 

]

{ #category : #visiting }
GCMVirtualCompositionModelLoader >> visitClassProductionExpression: aProductionExpressionNode [

	| element elementName properties |
	elementName := aProductionExpressionNode classname
		               ifNil: [ aProductionExpressionNode parent name value ]
		               ifNotNil: [ 
		               aProductionExpressionNode classname value ].

	element := self fm3ClassNamed: elementName.


	stack push: element. 
	properties := self visitCollection: aProductionExpressionNode terms.
	stack pop. 
	properties := properties select: [ :a | a isFM3Property ].
	properties do: [ :p | 
		| current |
		current := element propertyNamed: p name.
		current
			ifNil: [ 
				p type: element.
				element properties add: p ]
			ifNotNil: [ self loadInformationFrom: p into: current ] ]
]

{ #category : #visiting }
GCMVirtualCompositionModelLoader >> visitCodeProductionExpression: aSmaCCCodeProductionExpressionNode [ 
	^ nil
]

{ #category : #visiting }
GCMVirtualCompositionModelLoader >> visitCollection: aCollection [

	| flat ret |
	flat := OrderedCollection new.

	aCollection do: [ :a | 
		ret := a acceptVisitor: self.
		flat addAll: (ret asCollection reject: #isNil) ].
	^ flat
]

{ #category : #visiting }
GCMVirtualCompositionModelLoader >> visitErrorSymbol: aSmaCCErrorSymbolNode [ 
	^ nil
]

{ #category : #visiting }
GCMVirtualCompositionModelLoader >> visitFlagDirective: aSmaCCFlagDirectiveNode [ 

]

{ #category : #visiting }
GCMVirtualCompositionModelLoader >> visitGrammarDefinition: aSmaCCGrammarDefinitionNode [ 
	self visitCollection: aSmaCCGrammarDefinitionNode rules . 
]

{ #category : #visiting }
GCMVirtualCompositionModelLoader >> visitGroupTerm: aSmaCCGroupTermNode [ 
	^( self visitCollection: aSmaCCGroupTermNode expressions) reject:#isNil
]

{ #category : #visiting }
GCMVirtualCompositionModelLoader >> visitIdDirective: aSmaCCIdDirectiveNode [

	^ nil
]

{ #category : #visiting }
GCMVirtualCompositionModelLoader >> visitIgnoreVariableDirective: aSmaCCIgnoreVariableDirectiveNode [ 
	^ nil
]

{ #category : #visiting }
GCMVirtualCompositionModelLoader >> visitIgnoreVariableWarningDirective: aSmaCCIgnoreVariableWarningDirectiveNode [

	^ nil
]

{ #category : #visiting }
GCMVirtualCompositionModelLoader >> visitKeywordSymbol: aSmaCCKeywordSymbolNode [

	^ nil
]

{ #category : #visiting }
GCMVirtualCompositionModelLoader >> visitNodeNameDirective: aSmaCCNodeNameDirectiveNode [

	aSmaCCNodeNameDirectiveNode typeToken value = 'prefix' ifTrue: [ 
		^ astModelPrefix := aSmaCCNodeNameDirectiveNode name value ].
	aSmaCCNodeNameDirectiveNode typeToken value = 'suffix' ifTrue: [ 
		^ astModelSuffix := aSmaCCNodeNameDirectiveNode name value ].
	aSmaCCNodeNameDirectiveNode typeToken value = 'root' ifTrue: [ 
		^ astModelRoot := aSmaCCNodeNameDirectiveNode name value ].


]

{ #category : #visiting }
GCMVirtualCompositionModelLoader >> visitPostfixTerm: aSmaCCPostfixTermNode [

	| element cardinality |
	element := aSmaCCPostfixTermNode term acceptVisitor: self.
	element ifNil: [ ^ element ].
	element := element asCollection.
	cardinality := { 
		               ('*' -> #many).
		               ('+' -> #many).
		               ('?' -> #optional) } asDictionary at:
		               aSmaCCPostfixTermNode operator value.
		
	element do: [ :e | 
		cardinality = #many ifTrue: [ e isMultivalued: true ] ].
	^ element
]

{ #category : #visiting }
GCMVirtualCompositionModelLoader >> visitProductionExpression: aSmaCCProductionExpressionNode [

	^ (self visitCollection: aSmaCCProductionExpressionNode terms) 
		  reject: #isNil
]

{ #category : #visiting }
GCMVirtualCompositionModelLoader >> visitProductionRule: aProductionRule [
	stack push: (self fm3ClassNamed: aProductionRule name value).
	self visitCollection: aProductionRule expressions.
	stack pop.
]

{ #category : #visiting }
GCMVirtualCompositionModelLoader >> visitProductionSymbol: aSmaCCProductionSymbolNode [

	| varname vartype superClass element |
	self assert: aSmaCCProductionSymbolNode name isNotNil.
	vartype := self fm3ClassNamed: aSmaCCProductionSymbolNode name value.

	aSmaCCProductionSymbolNode variableNameToken ifNotNil: [ 
		varname := aSmaCCProductionSymbolNode variableNameToken value
			           copyReplaceAll: ''''
			           with: ''.

		element := FM3TypedProperty new
			           name: varname;
			           type: stack top;
			           addPropertyType: vartype;
			           yourself.
		model add: element.
		^ element ].


	^ ((aSmaCCProductionSymbolNode parent isKindOf:
		    SmaCCProductionExpressionNode) and: [ 
		   aSmaCCProductionSymbolNode parent parent isKindOf:
			   SmaCCProductionRuleNode ])
		  ifTrue: [ 
			  superClass := self fm3ClassNamed:
				                (self closerParentNameTo:
					                 aSmaCCProductionSymbolNode).
			  self set: superClass asSuperclassWithoutLoopingOf: vartype.

			  vartype ]
		  ifFalse: [ 
			  element := FM3TypeCompositionProperty new
				             addPropertyType: vartype;
				             yourself.
			  model add: element.
			  element ]
]

{ #category : #visiting }
GCMVirtualCompositionModelLoader >> visitScopeDirective: aSmaCCScopeDirectiveNode [

	^ nil
]

{ #category : #visiting }
GCMVirtualCompositionModelLoader >> visitStartDirective: aSmaCCStartDirectiveNode [

	self assert: astModelStart isNil.
	astModelStart := aSmaCCStartDirectiveNode symbols collect: #value
]

{ #category : #visiting }
GCMVirtualCompositionModelLoader >> visitSuperclassDirective: aSmaCCSuperclassDirectiveNode [ 
	^ nil
]

{ #category : #visiting }
GCMVirtualCompositionModelLoader >> visitTokenRule: aSmaCCTokenRuleNode [ 
]

{ #category : #visiting }
GCMVirtualCompositionModelLoader >> visitTokenSymbol: aSmaCCTokenSymbolNode [

	^ nil
]
