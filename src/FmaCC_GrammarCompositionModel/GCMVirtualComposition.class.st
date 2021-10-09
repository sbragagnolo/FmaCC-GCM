Class {
	#name : #GCMVirtualComposition,
	#superclass : #MiDraggableRoassalWidget,
	#instVars : [
		'metamodel'
	],
	#category : #'FmaCC_GrammarCompositionModel-Roassal'
}

{ #category : #initialization }
GCMVirtualComposition >> loadChart: aCanvas withElement: anElement [

	| builder clzzes |
	aCanvas @ RSCanvasController new.

	builder := RSUMLClassBuilder new.
	clzzes := metamodel elements select: [ :a | 
		          (a isFM3Class or: [ a isFM3Trait ]) and: [ 
			          a isPrimitive not ] ].

	builder
		container: aCanvas;
		classes: clzzes.
	builder modelDescriptor
		classname: #name;
		instVars: [ :a | 
			a properties
				select: [ :p | p isKindOf: FM3TypedProperty ]
				thenCollect: [ :p | 
					p name , ' : ' , (' | ' join: (p propertyTypes collect: #name)) ] ];
		methods: #(  );
		superclass: #superclass;
		isAbstract: false;
		aggregations: {  };
		compositions: (clzzes flatCollect: [ :a | 
					 (a properties select: [ :p | p isKindOf: FM3TypedProperty ]) 
						 flatCollect: [ :p | p propertyTypes collect: [ :t | a -> t ] ] ])
				asSet asOrderedCollection.

	builder build
]

{ #category : #initialization }
GCMVirtualComposition >> onParser: aParser [

	| loader |
	loader := GCMVirtualCompositionModelLoader new
		          parserClass: aParser;
		          loadTypingDefinition;
		          yourself.
	metamodel := loader model. 
]
