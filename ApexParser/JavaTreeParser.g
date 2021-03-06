tree grammar JavaTreeParser;

options {
    backtrack = true; 
    memoize = true;
    tokenVocab = Java;
    ASTLabelType = CommonTree;
    language=CSharp3;
}


@treeparser::header {
using ApexParser.ApexNodes;
using ApexParser.Scopes;
}

@treeparser::members {
 
   private bool mMessageCollectionEnabled = true;
		    private List<string> mMessages;

		    public void enableErrorMessageCollection(bool pNewState) {
		        mMessageCollectionEnabled = pNewState;
		        if (mMessages == null && mMessageCollectionEnabled) {
		            mMessages = new List<string>();
		        }
		    }
		    
	        public override void EmitErrorMessage(string pMessage)
	        {
	            if (mMessageCollectionEnabled) {
		            mMessages.Add(pMessage);
		        } else {
		            base.EmitErrorMessage(pMessage);
		        }
		    }
		    
		    public List<string> getMessages() {
		        return mMessages;
		    }

		    public bool hasErrors() {
	            return mMessages.Count>0;
		    }

	
}

// Starting point for parsing a Java file.
javaSource returns [IApexNode node]  
    :   
    	^(JAVA_SOURCE annotationList packageDeclaration? importDeclaration* typeDeclaration?) {node = $typeDeclaration.node;}
    ;

packageDeclaration //deprecate
    :   ^(PACKAGE qualifiedIdentifier)  
    ;
    
importDeclaration//deprecate
    :   ^(IMPORT STATIC? qualifiedIdentifier DOTSTAR?)
    ;
    
typeDeclaration returns [IApexNode node]
    :   ^(CLASS modifierList IDENT {node = new ApexClassNode($IDENT.Text, $modifierList.modifierList);} 
    (genericTypeParameterList {(node as ApexClassNode).Generics = $genericTypeParameterList.types;})?
     (extendsClause {(node as ApexClassNode).Extends = $extendsClause.types;})? implementsClause? classTopLevelScope) {node.AddRage($classTopLevelScope.nodes);} 
     
    |   ^(INTERFACE modifierList IDENT  {node = new ApexInterfaceNode($IDENT.Text, $modifierList.modifierList);} 
    (genericTypeParameterList {(node as ApexInterfaceNode).Generics = $genericTypeParameterList.types;})? 
    (extendsClause {(node as ApexInterfaceNode).Extends = $extendsClause.types;})? interfaceTopLevelScope) {node.AddRage($interfaceTopLevelScope.nodes);}
    
    |   ^(ENUM modifierList IDENT implementsClause? enumTopLevelScope) {node = new ApexEnum($IDENT.Text, $enumTopLevelScope.enumBlock, $modifierList.modifierList);}
    |   ^(AT modifierList IDENT annotationTopLevelScope)
    ;

extendsClause returns [List<ApexType> types]
    :
    	{types = new List<ApexType>();}
       ^(EXTENDS_CLAUSE (type {types.Add($type.type);})+)
    ;   
    
implementsClause returns [List<ApexType> types]
    :   ^(IMPLEMENTS_CLAUSE (type {types.Add($type.type);})+)
    ;
        
genericTypeParameterList returns[List<ApexType> types]
    :  
    	{types = new List<ApexType>();}
     ^(GENERIC_TYPE_PARAM_LIST (genericTypeParameter {types.Add($genericTypeParameter.type);})+)
    ;

genericTypeParameter returns [ApexType type]
    :   
    	^(IDENT {type = new ApexType($IDENT.Text);} (bound {type.AddTypes($bound.types);})?)
    ;
        
bound returns [IList<ApexType> types]
    :  
	{ types = new List<ApexType>();}
	^(EXTENDS_BOUND_LIST (type {types.Add($type.type);})+)
    ;

enumTopLevelScope  returns[EnumBlock enumBlock]
    :
    	{enumBlock = new EnumBlock();}
       ^(ENUM_TOP_LEVEL_SCOPE (enumConstant {enumBlock.AddName($enumConstant.name);})+ classTopLevelScope?)
    ;
enumConstant returns[string name]
    :   ^(IDENT annotationList arguments? classTopLevelScope?) {name = $IDENT.Text;}
    ;
    
    
classTopLevelScope returns [List<IApexNode> nodes]
    :
       ^(CLASS_TOP_LEVEL_SCOPE {nodes = new List<IApexNode>();} (classScopeDeclarations {nodes.Add($classScopeDeclarations.node);})*)  
    ;
    
classScopeDeclarations returns [IApexNode node]
    :   ^(CLASS_INSTANCE_INITIALIZER block) {node =  new ApexMethod($block.node);}//todo:
    |   ^(CLASS_STATIC_INITIALIZER block){node =  new ApexMethod($block.node);}
    |   {node = new ApexMethod();}
    	^(FUNCTION_METHOD_DECL modifierList genericTypeParameterList? type IDENT formalParameterList arrayDeclaratorList? throwsClause? (block {(node as ApexMethod).Block = $block.node;})?)
    	{var method = node as ApexMethod;method.Ident = $IDENT.Text;method.ModifierList = $modifierList.modifierList; method.Type = $type.type; method.parameters = $formalParameterList.parameters;}
    | {node = new ApexMethod();}
      ^(VOID_METHOD_DECL modifierList genericTypeParameterList? IDENT formalParameterList throwsClause? (block {(node as ApexMethod).Block = $block.node;})?)
      {var method = node as ApexMethod;method.Ident = $IDENT.Text;method.ModifierList = $modifierList.modifierList;  method.parameters = $formalParameterList.parameters;}
    |   ^(VAR_DECLARATION modifierList type variableDeclaratorList){node = new ApexFieldList($type.type, $modifierList.modifierList, $variableDeclaratorList.fields);}
    |   ^(CONSTRUCTOR_DECL modifierList genericTypeParameterList? formalParameterList throwsClause? block){node = new ApexConstructor($modifierList.modifierList);}
    |   ^(PROPERTY_DECL modifierList type IDENT propertyDeclaration ){node = new ApexProperty($IDENT.Text, $type.type, $modifierList.modifierList, $propertyDeclaration.nodes);}
    |   typeDeclaration {node = $typeDeclaration.node;}
    ;

propertyDeclaration returns [List<IApexNode> nodes]
:
 {nodes = new List<IApexNode>();}
 ('{' modifier? getRule (SEMI{nodes.Add(new Acessor(AcessorType.Get, $getRule.Name));}|getBlock = block {nodes.Add(new Acessor(AcessorType.Get, $getBlock.node, $getRule.Name));})
  (modifier? setRule (SEMI{nodes.Add(new Acessor(AcessorType.Set, $setRule.Name));}|setBlock = block {nodes.Add(new Acessor(AcessorType.Set, $setBlock.node, $setRule.Name));}) )? '}')
 | ('{' modifier? setRule (SEMI{nodes.Add(new Acessor(AcessorType.Set, $setRule.Name));}|setBlock = block {nodes.Add(new Acessor(AcessorType.Set, $setBlock.node, $setRule.Name));})
  (modifier? getRule (SEMI{nodes.Add(new Acessor(AcessorType.Get, $getRule.Name));}|getBlock = block {nodes.Add(new Acessor(AcessorType.Get, $getBlock.node, $getRule.Name));}) )?  '}')
;
getRule returns [string Name]
:
    {((input.LT(1)as CommonTree)!=null&& (input.LT(1)as CommonTree).Text == "get")}? IDENT {Name = $IDENT.Text;}
;
setRule returns [string Name]
:
    {(input.LT(1)as CommonTree)!=null&& (input.LT(1)as CommonTree).Text== "set"}? IDENT {Name = $IDENT.Text;}
;   

interfaceTopLevelScope returns [List<IApexNode> nodes]
    :
     {nodes = new List<IApexNode>();}
       ^(INTERFACE_TOP_LEVEL_SCOPE (interfaceScopeDeclarations {nodes.Add($interfaceScopeDeclarations.node);})*)
    ;
    
interfaceScopeDeclarations returns[IApexNode node]
    :  
      	{node = new ApexMethod();}
    	^(FUNCTION_METHOD_DECL modifierList genericTypeParameterList? type IDENT formalParameterList arrayDeclaratorList? throwsClause?)
	{var method = node as ApexMethod;method.Ident = $IDENT.Text;method.ModifierList = $modifierList.modifierList; method.Type = $type.type;method.parameters = $formalParameterList.parameters;}    	
    |   
	{node = new ApexMethod();}
    	^(VOID_METHOD_DECL modifierList genericTypeParameterList? IDENT formalParameterList throwsClause?)
    	{var method = node as ApexMethod;method.Ident = $IDENT.Text;method.ModifierList = $modifierList.modifierList; method.parameters = $formalParameterList.parameters;}  
                         // Interface constant declarations have been switched to variable
                         // declarations by 'java.g'; the parser has already checked that
                         // there's an obligatory initializer.
    |   ^(VAR_DECLARATION modifierList type variableDeclaratorList)
    	{node = new ApexFieldList($modifierList.modifierList, $variableDeclaratorList.fields);}
    |   typeDeclaration {node = $typeDeclaration.node;}
    ;

variableDeclaratorList returns [List<ApexField> fields]
    :  
    	{fields = new List<ApexField>();}
     	^(VAR_DECLARATOR_LIST (variableDeclarator {fields.Add($variableDeclarator.field);})+)
    ;

variableDeclarator returns [ApexField field]
//todo: add initializer to field
    :   ^(VAR_DECLARATOR variableDeclaratorId {field = $variableDeclaratorId.fieldId;} (variableInitializer { field.Initializer = $variableInitializer.initializer;})?)
    ;
    
variableDeclaratorId returns [ApexField fieldId]
    :   ^(IDENT {fieldId = new ApexField($IDENT.Text);} (arrayDeclaratorList {fieldId.IsArray = true;})?)
    ;

variableInitializer returns[IApexNode initializer]
    :   arrayInitializer {initializer = $arrayInitializer.initializer; }
    |   expression {initializer = $expression.node;}
    |   brokenExpression {initializer = $brokenExpression.node;}
    ;

arrayDeclarator
    :   LBRACK RBRACK
    ;

arrayDeclaratorList
    :   ^(ARRAY_DECLARATOR_LIST ARRAY_DECLARATOR*)  
    ;
    
arrayInitializer returns [ArrayInitializer initializer]
    :  
    	{initializer = new ArrayInitializer();}
     	^(ARRAY_INITIALIZER (variableInitializer {initializer.Add($variableInitializer.initializer);})*)
    ;

throwsClause
    :   ^(THROWS_CLAUSE qualifiedIdentifier+)
    ;

modifierList  returns [List<Modifier> modifierList]
    :   
       {modifierList = new List<Modifier>();}
    ^(MODIFIER_LIST (modifier {modifierList.Add($modifier.modifier);})*)
    ;

modifier returns [Modifier modifier]
    :   
  
    	(PUBLIC {modifier = Modifier.Public;}
    |   OVERRIDE {modifier = Modifier.Override;}
    |   VIRTUAL {modifier = Modifier.Virtual;}
    |   WITH_SHARING 
    |	WITHOUT_SHARING
    |   PROTECTED {modifier = Modifier.Protected;}
    |   PRIVATE {modifier = Modifier.Private;}
    |   STATIC {modifier = Modifier.Static;}
    |   ABSTRACT {modifier = Modifier.Abstract;}
    |   NATIVE
    |   SYNCHRONIZED
    |   TRANSIENT
    |   VOLATILE
    |   STRICTFP
    |	GLOBAL {modifier = Modifier.Global;}
    |   TEST_METHOD {modifier = Modifier.TestMethod;}
    |   localModifier)
    ;

localModifierList
    :   ^(LOCAL_MODIFIER_LIST localModifier*)
    ;

localModifier
    :   FINAL
    |   annotation
    ;

type returns [ApexType type]
    :   
    	^(TYPE (primitiveType | qualifiedTypeIdent {type = $qualifiedTypeIdent.type;}) (arrayDeclaratorList {type.IsArray = true;})?)
    ;

qualifiedTypeIdent  returns [ApexType type]
    :   ^(QUALIFIED_TYPE_IDENT (typeIdent {type =$typeIdent.type;})+) 
    ;

typeIdent returns [ApexType type]
    :   
    	^(IDENT {type = new ApexType($IDENT.Text);} (genericTypeArgumentList {type.AddRage($genericTypeArgumentList.types);})?)
    ;

primitiveType
    :   BOOLEAN
    |   CHAR
    |   BYTE
    |   SHORT
    |   INT
    |   LONG
    |   FLOAT
    |   DOUBLE
    ;

genericTypeArgumentList  returns [List<ApexType> types]
    :   ^(GENERIC_TYPE_ARG_LIST {types = new List<ApexType>();} (genericTypeArgument {types.Add($genericTypeArgument.genericTypeArgument);})+)
    ;
    
genericTypeArgument  returns [ApexType genericTypeArgument]
    :   
    	type {genericTypeArgument = $type.type;}
    |   ^(QUESTION genericWildcardBoundType?)
    ;

genericWildcardBoundType                                                                                                                      
    :   ^(EXTENDS type)
    |   ^(SUPER type)
    ;


formalParameterStandardDecl  returns [SignatureParam parameter]
    :   ^(FORMAL_PARAM_STD_DECL localModifierList type variableDeclaratorId) {parameter = new SignatureParam($type.type, $variableDeclaratorId.fieldId);}
    ;
    
formalParameterList returns [List<SignatureParam> parameters]
    :   
    {parameters = new List<SignatureParam>();}
    	^(FORMAL_PARAM_LIST (formalParameterStandardDecl {parameters.Add($formalParameterStandardDecl.parameter);})* 
    	(formalParameterVarargDecl {parameters.Add($formalParameterVarargDecl.parameter);})?) 
    ;
    
    
formalParameterVarargDecl returns [SignatureParam parameter]
    :   ^(FORMAL_PARAM_VARARG_DECL localModifierList type variableDeclaratorId) {parameter = new SignatureParam($type.type, $variableDeclaratorId.fieldId);}
    ;
    
qualifiedIdentifier returns [Identifier ident]
    :  
    	outerIdent = IDENT {ident = new Identifier($outerIdent.Text); }
    |   ^(DOT innerQual = qualifiedIdentifier innerIdent = IDENT){ident = new Identifier($innerIdent.Text);ident.SubIdent = $innerQual.ident; }
    ;
    
// ANNOTATIONS

annotationList
    :   ^(ANNOTATION_LIST annotation*)
    ;

annotation
    :   ^(AT qualifiedIdentifier annotationInit?)
    ;
    
annotationInit
    :   ^(ANNOTATION_INIT_BLOCK annotationInitializers)
    ;

annotationInitializers
    :   ^(ANNOTATION_INIT_KEY_LIST annotationInitializer+)
    |   ^(ANNOTATION_INIT_DEFAULT_KEY annotationElementValue)
    ;
    
annotationInitializer
    :   ^(IDENT annotationElementValue)
    ;
    
annotationElementValue
    :   ^(ANNOTATION_INIT_ARRAY_ELEMENT annotationElementValue*)
    |   annotation
    |   expression
    ;
    
annotationTopLevelScope
    :   ^(ANNOTATION_TOP_LEVEL_SCOPE annotationScopeDeclarations*)
    ;
    
annotationScopeDeclarations
    :   ^(ANNOTATION_METHOD_DECL modifierList type IDENT annotationDefaultValue?)
    |   ^(VAR_DECLARATION modifierList type variableDeclaratorList)
    |   typeDeclaration
    ;
    
annotationDefaultValue
    :   ^(DEFAULT annotationElementValue)
    ;

// STATEMENTS / BLOCKS

block returns [IApexNode node]
    :   
    	{node = new Block();}
    	^(BLOCK_SCOPE (blockStatement {node.Add($blockStatement.node);})*)
    ;
    
blockStatement returns [IApexNode node]
    :   
    	localVariableDeclaration {node= $localVariableDeclaration.varDeclaration;}
    |   typeDeclaration {node= $typeDeclaration.node;}
    |   statement { node = $statement.node; }
    | 	brokenExpression  {node = new BrokenExpression();}
    ;
brokenExpression  returns [IApexNode node] 
:
   ^(BROKEN_EXPRESSION expression {node = $expression.node;} DOT? SEMI?)
;
localVariableDeclaration returns [LocalVariableDeclaration varDeclaration]
    :   ^(VAR_DECLARATION localModifierList type variableDeclaratorList) {varDeclaration = new LocalVariableDeclaration($type.type, $variableDeclaratorList.fields);}
    ;
    
        

catches returns [List<CatchBlock> catches]
    :   ^(CATCH_CLAUSE_LIST catchClause+)
    ;
statement returns [IApexNode node]
    :   block { node = $block.node; }
    |   { node = new IfStatement(); } ^(IF parenthesizedExpression 
    	trueStatement = statement { var ifStatement = node as IfStatement; 
    		ifStatement.BoolExpression = $parenthesizedExpression.node; 
    		ifStatement.TrueStatement = $trueStatement.node; } 
    	( elseStatement = statement { (node as IfStatement).ElseStatement = $elseStatement.node; })?)
    |   ^(FOR forInit forCondition forUpdater forStatementInner = statement)
    	{var forStatement  = new ForStatement(); forStatement.Init = $forInit.init; forStatement.Condition = $forCondition.condition;forStatement.Update = $forUpdater.updates;forStatement.Statement = $forStatementInner.node; node = forStatement; }
    |   ^(FOR_EACH localModifierList type IDENT expression foreachStatementInner = statement) 
    	{node = new ForEachStatement($type.type, $IDENT.Text, $expression.node, $foreachStatementInner.node); }
    |   ^(WHILE parenthesizedExpression whileInnerStatement = statement)
	{node = new WhileStatement($parenthesizedExpression.node, $whileInnerStatement.node);}
    |   ^(DO doInnerStatemnt = statement parenthesizedExpression) 
    	{node = new DoStatement($parenthesizedExpression.node, $doInnerStatemnt.node);}
    |   
    	{node = new TryStatemnt();}
    	^(TRY tryBlock = block{var tryStatemnt = node as TryStatemnt;tryStatemnt.Try = $tryBlock.node;} 
    	(catches{var tryStatemnt = node as TryStatemnt;tryStatemnt.Catches = $catches.catches;})? 
    	(finalyBlock = block{var tryStatemnt = node as TryStatemnt;tryStatemnt.Finaly = $finalyBlock.node;})?)
    |   ^(SWITCH parenthesizedExpression switchBlockLabels) 
    	{node = new SwitchStatement($parenthesizedExpression.node, $switchBlockLabels.sBlock);}
    |   ^(SYNCHRONIZED parenthesizedExpression block) //todo????
    |  	{node = new ReturnStatement();}  ^(RETURN (expression {(node as ReturnStatement).Expression = $expression.node;})?)
    | 	{node = new ThrowStatement();}   ^(THROW expression  {(node as ThrowStatement).Expression = $expression.node;})
    |   ^(BREAK IDENT?) {node = new BreakStatement();}
    |   ^(CONTINUE IDENT?){node = new ContinueStatement();}
    |   ^(LABELED_STATEMENT IDENT labelStatement = statement){node = new LabelStatement($IDENT.Text, $labelStatement.node);}
    |   expression { node = $expression.node; }
    |   SEMI {node = new EmptyStatement();}
    ;
        
    
catchClause returns [CatchBlock catchResult]
    :   ^(CATCH formalParameterStandardDecl block){catchResult = new CatchBlock($block.node);}
    ;

switchBlockLabels returns[SwitchBlock sBlock]
    :   
    {sBlock = new SwitchBlock();}
    	^(SWITCH_BLOCK_LABEL_LIST (beforeDefaultCase = switchCaseLabel {sBlock.Add($beforeDefaultCase.caseB);})*
    	 (switchDefaultLabel {sBlock.Add($switchDefaultLabel.caseB);})? ( aftereDefaultCase = switchCaseLabel {sBlock.Add($aftereDefaultCase.caseB);})*)
    ;
        
switchCaseLabel returns[SwitchCaseBlock caseB]
    :   
    	^(CASE expression {caseB = new SwitchCaseBlock($expression.node);} (blockStatement {caseB.Add($blockStatement.node);})*)
    ;
    
switchDefaultLabel returns [SwitchCaseBlock caseB]
    :   
    	{caseB = new SwitchCaseBlock();}
    	^(DEFAULT (blockStatement {caseB.Add($blockStatement.node);})*)
    ;
    
forInit returns [ForInit init]
    :   ^(FOR_INIT (localVariableDeclaration {init = new ForInit($localVariableDeclaration.varDeclaration);} |  {init = new ForInit();} (expression {init.Add($expression.node);})*)?)
    ;
    
forCondition returns [IApexNode condition]
    :   ^(FOR_CONDITION (expression {condition = $expression.node;})?)
    ;
    
forUpdater returns [List<IApexNode> updates]
    :
    {updates = new List<IApexNode>();}   
    ^(FOR_UPDATE (expression {updates.Add($expression.node);})*)
    ;
    
// EXPRESSIONS

parenthesizedExpression returns [IApexNode node]
    :   ^(PARENTESIZED_EXPR expression) {node = $expression.node;}
    ;
    
expression returns [IApexNode node]
    :   ^(EXPR expr) {node = $expr.node;}
    ;

expr returns [IApexNode node]
    :   ^(ASSIGN  a=expr b=expr) {node = new AssigmentExpression($a.node, $b.node);}
    |   ^(PLUS_ASSIGN a=expr b=expr){node = new AssigmentExpression($a.node, $b.node);}
    |   ^(MINUS_ASSIGN a=expr b=expr){node = new AssigmentExpression($a.node, $b.node);}
    |   ^(STAR_ASSIGN a=expr b=expr){node = new AssigmentExpression($a.node, $b.node);}
    |   ^(DIV_ASSIGN a=expr b=expr){node = new AssigmentExpression($a.node, $b.node);}
    |   ^(AND_ASSIGN a=expr b=expr){node = new AssigmentExpression($a.node, $b.node);}
    |   ^(OR_ASSIGN a=expr b=expr){node = new AssigmentExpression($a.node, $b.node);}
    |   ^(XOR_ASSIGN a=expr b=expr){node = new AssigmentExpression($a.node, $b.node);}
    |   ^(MOD_ASSIGN a=expr b=expr){node = new AssigmentExpression($a.node, $b.node);}
    |   ^(BIT_SHIFT_RIGHT_ASSIGN a=expr b=expr){node = new AssigmentExpression($a.node, $b.node);}
    |   ^(SHIFT_RIGHT_ASSIGN a=expr b=expr){node = new AssigmentExpression($a.node, $b.node);}
    |   ^(SHIFT_LEFT_ASSIGN a=expr b=expr){node = new AssigmentExpression($a.node, $b.node);}
    
    |   ^(QUESTION ifexpression=expr a=expr b=expr){node = new TernarIfExpression($ifexpression.node, $a.node, $b.node);}
    
    |   ^(LOGICAL_OR a=expr b=expr){node = new LogicalDoubleExpression($a.node, $b.node);}
    |   ^(LOGICAL_AND a=expr b=expr){node = new LogicalDoubleExpression($a.node, $b.node);}
    
    |   ^(OR a=expr b=expr){node = new BitOperationExpression($a.node, $b.node);}
    |   ^(XOR a=expr b=expr){node = new BitOperationExpression($a.node, $b.node);}
    |   ^(AND a=expr b=expr){node = new BitOperationExpression($a.node, $b.node);}
    |   ^(EQUAL a=expr b=expr) {node = new BynaryOperationWithBooleanResultExpression($a.node, $b.node);}
    |   ^(NOT_EQUAL a=expr b=expr){node = new BynaryOperationWithBooleanResultExpression($a.node, $b.node);}
    
    |   ^(INSTANCEOF a=expr type){node = new InstanceOf($type.type, $a.node);}
    
    |   ^(LESS_OR_EQUAL a=expr b=expr){node = new BynaryOperationWithBooleanResultExpression($a.node, $b.node);}
    |   ^(GREATER_OR_EQUAL a=expr b=expr){node = new BynaryOperationWithBooleanResultExpression($a.node, $b.node);}
    |   ^(GREATER_THAN a=expr b=expr){node = new BynaryOperationWithBooleanResultExpression($a.node, $b.node);}
    |   ^(LESS_THAN a=expr b=expr){node = new BynaryOperationWithBooleanResultExpression($a.node, $b.node);}
    
    |   ^(BIT_SHIFT_RIGHT a=expr b=expr){node = new BitOperationExpression($a.node, $b.node);}
    |   ^(SHIFT_RIGHT a=expr b=expr){node = new BitOperationExpression($a.node, $b.node);}
    |   ^(SHIFT_LEFT a=expr b=expr){node = new BitOperationExpression($a.node, $b.node);}
        
    |   ^(PLUS a=expr b=expr){node = new MathExpression($a.node, $b.node);}
    |   ^(MINUS a=expr b=expr){node = new MathExpression($a.node, $b.node);}
    |   ^(STAR a=expr b=expr){node = new MathExpression($a.node, $b.node);}
    |   ^(DIV a=expr b=expr){node = new MathExpression($a.node, $b.node);}
    |   ^(MOD a=expr b=expr){node = new MathExpression($a.node, $b.node);}
    
    |   ^(UNARY_PLUS a=expr)//todo:???
    |   ^(UNARY_MINUS a=expr)//todo:???
    |   ^(PRE_INC a=expr) {node = $a.node;}
    |   ^(PRE_DEC a=expr){node = $a.node;}
    |   ^(POST_INC a=expr){node = $a.node;}
    |   ^(POST_DEC a=expr){node = $a.node;}
    |   ^(NOT a=expr){node = $a.node;}
    |   ^(LOGICAL_NOT a=expr){node = $a.node;}
    
    |   ^(CAST_EXPR type a=expr){node = new CastExpression($type.type, $a.node);}
    |   primaryExpression {node = $primaryExpression.node;}
    ;
        
primaryExpression returns [IApexNode node]
    :   ^(  DOT
            (   dotPrimaryExpression =primaryExpression
                (   
                    IDENT {node = new DotExpression($IDENT.Text,$dotPrimaryExpression.node);}
                |   THIS  {node = new DotExpression(DotScope.This,$dotPrimaryExpression.node);}
                |   SUPER {node = new DotExpression(DotScope.Super,$dotPrimaryExpression.node);}
                |   innerNewExpression {node = new DotExpression($innerNewExpression.node, $dotPrimaryExpression.node);}
                |   CLASS {node = new DotExpression(DotScope.Class,$dotPrimaryExpression.node);}
                )
	    |   primitiveType CLASS//deprecate
            |   VOID CLASS//todo:????
            )
        )
    |   parenthesizedExpression {node = $parenthesizedExpression.node;}
    |   IDENT {node = new IdentExpression($IDENT.Text); }
    |   ^(METHOD_CALL methodPrimoryExpression = primaryExpression {node = new MethodCallExpression($methodPrimoryExpression.node);}
     	(genericTypeArgumentList {var method = node as MethodCallExpression; method.Generic = $genericTypeArgumentList.types;})? arguments) 
     	{var method = node as MethodCallExpression; method.Arguments = $arguments.nodes;}
    |   explicitConstructorCall {node = $explicitConstructorCall.call;}
    |   ^(ARRAY_ELEMENT_ACCESS primaryExpression expression)
    |   literal {node = $literal.vale;}
    |   newExpression {node = $newExpression.node;}
    |   THIS {node = new ThisExpression();}
    |   arrayTypeDeclarator {node = $arrayTypeDeclarator.declarator;}
    |   SUPER {node = new SuperExpression();}
    ;
    

arrayTypeDeclarator returns [ArrayDeclarator declarator]
    :  
    	{declarator = new ArrayDeclarator();}
     	^(ARRAY_DECLARATOR (innerArrDec = arrayTypeDeclarator {declarator.SubDeclarator =$innerArrDec.declarator; } | qualifiedIdentifier {declarator.Type = $qualifiedIdentifier.ident;} | primitiveType))
    ;
explicitConstructorCall returns[ExplicitContructorCall call]
    :   
	{call = new ExplicitContructorCall();}
        ^(THIS_CONSTRUCTOR_CALL (genericTypeArgumentList {call.Gerics = $genericTypeArgumentList.types;})? arguments {call.Arguments = $arguments.nodes; call.Scope = DotScope.This;}) 
    |   ^(SUPER_CONSTRUCTOR_CALL (primaryExpression {call.PrimoryExpression = $primaryExpression.node;})?  (genericTypeArgumentList {call.Gerics = $genericTypeArgumentList.types;})?
     	arguments {call.Arguments = $arguments.nodes; call.Scope = DotScope.This;})
    ;



innerNewExpression  returns [IApexNode node]// something like 'InnerType innerType = outer.new InnerType();'
    :   ^(CLASS_CONSTRUCTOR_CALL genericTypeArgumentList? IDENT arguments classTopLevelScope?)//todo:
    ;
newExpression returns [IApexNode node]
    :  
    	{node = new StaticArrayCreator();}
    	^(  STATIC_ARRAY_CREATOR
            (   primitiveType newArrayConstruction
            |  ( genericTypeArgumentList {var arrayCreator = node as StaticArrayCreator;arrayCreator.GenericsArguments = $genericTypeArgumentList.types; })?
            	 qualifiedTypeIdent innerNewArrayConst = newArrayConstruction 
            	 {var arrayCreator = node as StaticArrayCreator;arrayCreator.Type = $qualifiedTypeIdent.type;arrayCreator.ArrayConstructor = $innerNewArrayConst.node;  }
            )
        )
    |  
    	{node = new ClassConstructorCall();}
     ^(CLASS_CONSTRUCTOR_CALL (genericTypeArgumentList {var classConstructroCall = node as ClassConstructorCall; classConstructroCall.GenericsArguments = $genericTypeArgumentList.types;})? 
     qualifiedTypeIdent arguments  {var classConstructroCall = node as ClassConstructorCall; classConstructroCall.Type = $qualifiedTypeIdent.type; classConstructroCall.arguments = $arguments.nodes;}
      (classTopLevelScope)?)
    ;

    
newArrayConstruction returns [NewArray node]
    :   {node= new NewArray();}
    	arrayDeclaratorList arrayInitializer {node.ArrayInitializer = $arrayInitializer.initializer; }
    |   (expression {node.Add($expression.node);})+ arrayDeclaratorList?
    ;

arguments returns [List<IApexNode> nodes]
    :   
	    {nodes = new List<IApexNode>();} ^(ARGUMENT_LIST (expression {nodes.Add($expression.node);})*)
    ;

literal returns [ContantExpression vale]
    :   HEX_LITERAL {vale = new ContantExpression("integer", $HEX_LITERAL.Text);}
    |   OCTAL_LITERAL {vale = new ContantExpression("integer", $OCTAL_LITERAL.Text);}
    |   DECIMAL_LITERAL {vale = new ContantExpression("integer", $DECIMAL_LITERAL.Text);}
    |   FLOATING_POINT_LITERAL {vale = new ContantExpression("double", $FLOATING_POINT_LITERAL.Text);}
    |   CHARACTER_LITERAL {vale = new ContantExpression("char", $CHARACTER_LITERAL.Text);}
    |   STRING_LITERAL {vale = new ContantExpression("string", $STRING_LITERAL.Text);}
    |   TRUE {vale = new ContantExpression("boolean", $TRUE.Text);}
    |   FALSE {vale = new ContantExpression("boolean", $FALSE.Text);}
    |   NULL {vale = new ContantExpression("null", $NULL.Text);}
    ;