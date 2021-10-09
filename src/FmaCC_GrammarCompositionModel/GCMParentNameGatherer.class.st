Class {
	#name : #GCMParentNameGatherer,
	#superclass : #Object,
	#category : #'FmaCC_GrammarCompositionModel-ModelLoader'
}

{ #category : #visiting }
GCMParentNameGatherer >> visitClassProductionExpression: aSmaCCClassProductionExpressionNode [

	^ aSmaCCClassProductionExpressionNode classname
		  ifNotNil: [ :n | n value ]
		  ifNil: [ 
		  aSmaCCClassProductionExpressionNode parent acceptVisitor: self ]
]

{ #category : #visiting }
GCMParentNameGatherer >> visitPostfixTerm: aSmaCCPostfixTermNode [ 
	^ aSmaCCPostfixTermNode parent acceptVisitor: self
]

{ #category : #visiting }
GCMParentNameGatherer >> visitProductionExpression: aSmaCCProductionExpressionNode [

	^ aSmaCCProductionExpressionNode parent acceptVisitor: self
]

{ #category : #visiting }
GCMParentNameGatherer >> visitProductionRule: aSmaCCProductionRuleNode [

	^ aSmaCCProductionRuleNode name
		  ifNotNil: [ :a | a value ]
		  ifNil: [ aSmaCCProductionRuleNode parent acceptVisitor: self ]
]
