Class {
	#name : #GCMConcreteComposition,
	#superclass : #GCMVirtualComposition,
	#category : #'FmaCC_GrammarCompositionModel-Roassal'
}

{ #category : #initialization }
GCMConcreteComposition >> onParser: aParser [

	| concreteLoader |
	concreteLoader := GCMConcreteCompositionModelLoader new
		                  parserClass: aParser;
		                  loadConcreteModel.
	metamodel := concreteLoader model
		             inspect;
		             yourself
]
