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
    :   ^(JAVA_SOURCE annotationList packageDeclaration? importDeclaration* typeDeclaration?) {node = $typeDeclaration.node;}
    ;

packageDeclaration 
    :   ^(PACKAGE qualifiedIdentifier)  
    ;
    
importDeclaration
    :   ^(IMPORT STATIC? qualifiedIdentifier DOTSTAR?)
    ;
    
typeDeclaration returns [IApexNode node]
    :   ^(CLASS modifierList IDENT genericTypeParameterList? extendsClause? implementsClause? classTopLevelScope) {node = $classTopLevelScope.node;}
    |   ^(INTERFACE modifierList IDENT genericTypeParameterList? extendsClause? interfaceTopLevelScope)
    |   ^(ENUM modifierList IDENT implementsClause? enumTopLevelScope)
    |   ^(AT modifierList IDENT annotationTopLevelScope)
    ;

extendsClause // actually 'type' for classes and 'type+' for interfaces, but this has 
              // been resolved by the parser grammar.
    :   ^(EXTENDS_CLAUSE type+)
    ;   
    
implementsClause
    :   ^(IMPLEMENTS_CLAUSE type+)
    ;
        
genericTypeParameterList
    :   ^(GENERIC_TYPE_PARAM_LIST genericTypeParameter+)
    ;

genericTypeParameter
    :   ^(IDENT bound?)
    ;
        
bound
    :   ^(EXTENDS_BOUND_LIST type+)
    ;

enumTopLevelScope
    :   ^(ENUM_TOP_LEVEL_SCOPE enumConstant+ classTopLevelScope?)
    ;
    
enumConstant
    :   ^(IDENT annotationList arguments? classTopLevelScope?)
    ;
    
    
classTopLevelScope returns [IApexNode node]
    :
       ^(CLASS_TOP_LEVEL_SCOPE {node = new ApexClassNode();} (classScopeDeclarations {((ApexClassNode)node).Add($classScopeDeclarations.node);})*)  
    ;
    
classScopeDeclarations returns [IApexNode node]
    :   ^(CLASS_INSTANCE_INITIALIZER block) {node = null;}
    |   ^(CLASS_STATIC_INITIALIZER block){node = null;}
    |   {node = new ApexMethod();}
    	^(FUNCTION_METHOD_DECL modifierList genericTypeParameterList? type IDENT formalParameterList arrayDeclaratorList? throwsClause? (block {(node as ApexMethod).Block = $block.node;})?)
    	{var method = node as ApexMethod;method.Ident = $IDENT.Text;method.ModifierList = $modifierList.modifierList; method.Type = $type.type;}
    |   ^(VOID_METHOD_DECL modifierList genericTypeParameterList? IDENT formalParameterList throwsClause? block?)
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

interfaceTopLevelScope
    :   ^(INTERFACE_TOP_LEVEL_SCOPE interfaceScopeDeclarations*)
    ;
    
interfaceScopeDeclarations
    :   ^(FUNCTION_METHOD_DECL modifierList genericTypeParameterList? type IDENT formalParameterList arrayDeclaratorList? throwsClause?)
    |   ^(VOID_METHOD_DECL modifierList genericTypeParameterList? IDENT formalParameterList throwsClause?)
                         // Interface constant declarations have been switched to variable
                         // declarations by 'java.g'; the parser has already checked that
                         // there's an obligatory initializer.
    |   ^(VAR_DECLARATION modifierList type variableDeclaratorList)
    |   typeDeclaration
    ;

variableDeclaratorList returns [List<ApexField> fields]
    :  
    	{fields = new List<ApexField>();}
     	^(VAR_DECLARATOR_LIST (variableDeclarator {fields.Add($variableDeclarator.field);})+)
    ;

variableDeclarator returns [ApexField field]
//todo: add initializer to field
    :   ^(VAR_DECLARATOR variableDeclaratorId {field = $variableDeclaratorId.fieldId;} variableInitializer?)
    ;
    
variableDeclaratorId returns [ApexField fieldId]
    :   ^(IDENT {fieldId = new ApexField($IDENT.Text);} (arrayDeclaratorList {fieldId.IsArray = true;})?)
    ;

variableInitializer
    :   arrayInitializer
    |   expression
    |   brokenExpression 
    ;

arrayDeclarator
    :   LBRACK RBRACK
    ;

arrayDeclaratorList
    :   ^(ARRAY_DECLARATOR_LIST ARRAY_DECLARATOR*)  
    ;
    
arrayInitializer
    :   ^(ARRAY_INITIALIZER variableInitializer*)
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

formalParameterList
    :   ^(FORMAL_PARAM_LIST formalParameterStandardDecl* formalParameterVarargDecl?) 
    ;
    
formalParameterStandardDecl
    :   ^(FORMAL_PARAM_STD_DECL localModifierList type variableDeclaratorId)
    ;
    
formalParameterVarargDecl
    :   ^(FORMAL_PARAM_VARARG_DECL localModifierList type variableDeclaratorId)
    ;
    
qualifiedIdentifier 
    :   IDENT
    |   ^(DOT qualifiedIdentifier IDENT)
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
    	
    	localVariableDeclaration {node= new LocalVariableDeclaration();}
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
    
        
statement returns [IApexNode node]
    :   block { node = $block.node; }
    |   { node = new IfStatement(); } ^(IF parenthesizedExpression 
    	trueStatement = statement { var ifStatement = node as IfStatement; 
    		ifStatement.BoolExpression = $parenthesizedExpression.node; 
    		ifStatement.TrueStatement = $trueStatement.node; } 
    	( elseStatement = statement { (node as IfStatement).ElseStatement = $elseStatement.node; })?)
    |   ^(FOR forInit forCondition forUpdater statement)
    |   ^(FOR_EACH localModifierList type IDENT expression statement) 
    |   ^(WHILE parenthesizedExpression statement)
    |   ^(DO statement parenthesizedExpression)
    |   ^(TRY block catches? block?)  // The second optional block is the optional finally block.
    |   ^(SWITCH parenthesizedExpression switchBlockLabels)
    |   ^(SYNCHRONIZED parenthesizedExpression block)
    |   ^(RETURN expression?)
    |   ^(THROW expression)
    |   ^(BREAK IDENT?)
    |   ^(CONTINUE IDENT?)
    |   ^(LABELED_STATEMENT IDENT statement)
    |   expression { node = $expression.node; }
    |   SEMI // Empty statement.
    ;
        
catches
    :   ^(CATCH_CLAUSE_LIST catchClause+)
    ;
    
catchClause
    :   ^(CATCH formalParameterStandardDecl block)
    ;

switchBlockLabels
    :   ^(SWITCH_BLOCK_LABEL_LIST switchCaseLabel* switchDefaultLabel? switchCaseLabel*)
    ;
        
switchCaseLabel
    :   ^(CASE expression blockStatement*)
    ;
    
switchDefaultLabel
    :   ^(DEFAULT blockStatement*)
    ;
    
forInit
    :   ^(FOR_INIT (localVariableDeclaration | expression*)?)
    ;
    
forCondition
    :   ^(FOR_CONDITION expression?)
    ;
    
forUpdater
    :   ^(FOR_UPDATE expression*)
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
            (   primaryExpression
                (   IDENT
                |   THIS
                |   SUPER
                |   innerNewExpression
                |   CLASS
                )
            |   primitiveType CLASS
            |   VOID CLASS
            )
        )
    |   parenthesizedExpression {node = $parenthesizedExpression.node;}
    |   IDENT
    |   ^(METHOD_CALL primaryExpression genericTypeArgumentList? arguments)
    |   explicitConstructorCall
    |   ^(ARRAY_ELEMENT_ACCESS primaryExpression expression)
    |   literal
    |   newExpression
    |   THIS
    |   arrayTypeDeclarator
    |   SUPER
    ;
    
explicitConstructorCall
    :   ^(THIS_CONSTRUCTOR_CALL genericTypeArgumentList? arguments)
    |   ^(SUPER_CONSTRUCTOR_CALL primaryExpression? genericTypeArgumentList? arguments)
    ;

arrayTypeDeclarator
    :   ^(ARRAY_DECLARATOR (arrayTypeDeclarator | qualifiedIdentifier | primitiveType))
    ;

newExpression
    :   ^(  STATIC_ARRAY_CREATOR
            (   primitiveType newArrayConstruction
            |   genericTypeArgumentList? qualifiedTypeIdent newArrayConstruction
            )
        )
    |   ^(CLASS_CONSTRUCTOR_CALL genericTypeArgumentList? qualifiedTypeIdent arguments classTopLevelScope?)
    ;

innerNewExpression // something like 'InnerType innerType = outer.new InnerType();'
    :   ^(CLASS_CONSTRUCTOR_CALL genericTypeArgumentList? IDENT arguments classTopLevelScope?)
    ;
    
newArrayConstruction
    :   arrayDeclaratorList arrayInitializer
    |   expression+ arrayDeclaratorList?
    ;

arguments
    :   ^(ARGUMENT_LIST expression*)
    ;

literal 
    :   HEX_LITERAL
    |   OCTAL_LITERAL
    |   DECIMAL_LITERAL
    |   FLOATING_POINT_LITERAL
    |   CHARACTER_LITERAL
    |   STRING_LITERAL
    |   TRUE
    |   FALSE
    |   NULL
    ;