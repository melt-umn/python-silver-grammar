grammar edu:umn:cs:melt:python ;




--Based on the Berkeley Grammar: http://inst.eecs.berkeley.edu/~cs164/fa11/python-grammar.html
--and 
-- http://docs.python.org/release/2.5.4/ref/ref.html and http://docs.python.org/2/tutorial/
--and 
-- the Python 2.4.6 grammar specification included with Python 2.4.6: Python-2.4.6/Grammar/Grammar



---------------------------------Parser Attributes

	
 parser attribute parenLevel :: Integer action {
    parenLevel = 0;
 };

 parser attribute depths :: [Integer] action {
    depths = [0];
 };


---------------------------------Disambiguation Functions


 --These three disambiguate longStringComment_t from other strings.


 disambiguate LongStringComment_t, LongStringFuncDocString_t
 {
    pluck LongStringFuncDocString_t;
 }


 disambiguate LongStringComment_t,LongStringFuncDocString_t, LongString_t
 {
    pluck LongStringFuncDocString_t;
 }




 disambiguate LongStringComment_t, LongString_t
 {
    	pluck LongString_t;
 }

 --These 5 functions disambiguate whitespace terminals from each other


 disambiguate Newline_t, IgnoredNewline
 {
   pluck if (parenLevel > 0)
         then IgnoredNewline
         else Newline_t;
 }





 disambiguate IgnoredNewline, Dedent_t
 {
   pluck if (parenLevel > 0)
         then IgnoredNewline
         else Dedent_t;
  
 }




 disambiguate IgnoredNewline, Indent_t
 {
   pluck if (parenLevel > 0)
         then IgnoredNewline
         else Indent_t;
   
 }





 disambiguate Newline_t, IgnoredNewline, Dedent_t
 {
    local attribute newDepth :: Integer = removeExtraWhitespaceAndCalculateLength(lexeme);
    pluck if(parenLevel > 0)
          then IgnoredNewline
          else if(newDepth < head(depths))  
               then Dedent_t 
               else Newline_t;
 }



 disambiguate Newline_t, IgnoredNewline, DedentRepair_t
 {
    local attribute newDepth :: Integer = removeExtraWhitespaceAndCalculateLength(lexeme);
    pluck if(parenLevel > 0)
          then IgnoredNewline
          else if(newDepth < head(depths))  
               then DedentRepair_t 
               else Newline_t;
 }

------------------------Auxillary Functions-------------------------------------------


 function removeExtraWhitespaceAndCalculateLength
 Integer ::= input::String
 {
    return length(removeExtraWhitespace(input))-1;
 }

 function removeExtraWhitespace
 String ::= input::String
 {
    return substring(lastIndexOf("\n", input),length(input), input);
 }


------------------------Terminals----------------------------------------------




 lexer class keywds;
 lexer class specialNumbers;




 --Whitepace

 ignore terminal Comment_t   /#([^\r\n])*/ action{   };
 ignore terminal Comment2_t   /(\n[\ \t]*)+#([^\r\n])*/ action{   };
 ignore terminal LongStringComment_t  /(\n[\ \t]*)*('''([^']|'[^']|''[^'])*''')|("""([^"]|"[^"]|""[^"])*""")/ action{   };
 ignore terminal Spaces_t  /[\ \t]+|(\\\n)/ action{   };
 ignore terminal IgnoredNewline  /(\n[\ \t]*)+/ action{   };
 terminal Newline_t  /(\n[\ \t]*)+/ action{   };






 --Keywords

 terminal LambdaKwd_t   /lambda/   lexer classes { keywds }, action{   } ;
 terminal ClassKwd_t   /class/ lexer classes { keywds } , action{   } ;
 terminal ExecKwd_t   /exec/ lexer classes { keywds } , action{   } ;
 terminal GlobalKwd_t   /global/ lexer classes { keywds } , action{   } ;
 terminal FromKwd_t   /from/ lexer classes { keywds } , action{   } ;
 terminal ImportKwd_t   /import/ lexer classes { keywds } , action{   } ;
 terminal ContinueKwd_t   /continue/ lexer classes { keywds } , action{   } ;
 terminal BreakKwd_t   /break/ lexer classes { keywds } , action{   } ;
 terminal RaiseKwd_t   /raise/ lexer classes { keywds } , action{   } ;
 terminal ReturnKwd_t  /return/ lexer classes { keywds }, action{   } ;
 terminal PassKwd_t  /pass/ lexer classes { keywds } , action{   } ;
 terminal DelKwd_t  /del/ lexer classes { keywds } , action{   } ;
 terminal YieldKwd_t  /yield/ lexer classes { keywds } , action{   } ;
 terminal AssertKwd_t  /assert/ lexer classes { keywds } , action{   } ;
 terminal DefKwd_t  /def/ lexer classes { keywds } , action{   } ;
 terminal WithKwd_t  /with/ lexer classes { keywds } , action{   } ;
 terminal AsKwd_t  /as/ lexer classes { keywds } , action{   } ;
 terminal FinallyKwd_t  /finally/ lexer classes { keywds } , action{   } ;
 terminal ExceptKwd_t  /except/ lexer classes { keywds } , action{   } ;
 terminal TryKwd_t  /try/ lexer classes { keywds } , action{   } ;
 terminal IfKwd_t  /if/ lexer classes { keywds } , action{   } ;
 terminal ElifKwd_t  /elif/ lexer classes { keywds } , action{   } ;
 terminal ElseKwd_t  /else/ lexer classes { keywds } , action{   } ;
 terminal ForKwd_t  /for/ lexer classes { keywds } , action{   } ;
 terminal PrintKwd_t  /print/ lexer classes { keywds } , action{   } ;
 terminal WhileKwd_t  /while/ lexer classes { keywds } , action{   } ;
 terminal OrWordKwd_t  /or/ lexer classes { keywds } ;
 terminal AndWordKwd_t  /and/ lexer classes { keywds } , action{   } ;
 terminal NotWordKwd_t  /not/ lexer classes { keywds } , action{   } ;
 terminal IsKwd_t  /is/  lexer classes { keywds }  , action{   } ;
 terminal InKwd_t  /in/  lexer classes { keywds }  , action{   } ;
 terminal IsNotKwd_t  /is[\s\t\ ]*not/   lexer classes { keywds } , action{   } ;
 terminal NotInKwd_t  /not[\s\t\ ]*in/   lexer classes { keywds } , action{   } ;




 --Special class of numbers with lexical precdence over identifier_t

 terminal HexInteger_t  /0[xX][0-9A-Fa-f]+/   lexer classes { specialNumbers } , action{   } ;
 terminal OctInteger_t  /0[0-7]+/   lexer classes { specialNumbers } , action{   } ;



 --Identifiers

 terminal Identifier_t  /[a-zA-Z_][a-zA-Z_0-9]*/ submits to { keywds, specialNumbers } , action{   } ;


 --Other numbers

 terminal Exponent_t  /[eE][\+\-]?[0-9]+/  action{   } ;
 terminal PointFloat_t  /(([0-9]+)?\.[0-9]+)|[0-9]+\./  action{   } ;
 terminal PointFloatExponent_t  /((([0-9]+)?\.[0-9]+)|[0-9]+\.)[eE][\+\-]?[0-9]+/  action{   } ;
 terminal PointIntExponent_t  /[0-9]+[eE][\+\-]?[0-9]+/  action{   } ;
 terminal LongIntegerPart_t  /lL/  action{   } ;
 terminal DecimalInteger_t  /([1-9][0-9]*)|0/  action{   } ;
 terminal DecimalIntegerLong_t  /(([1-9][0-9]*)|0)[lL]/  action{   } ;
 terminal HexIntegerLong_t  /(0[xX][0-9A-Fa-f]+)[lL]/   lexer classes { specialNumbers },  action{   } ;
 terminal OctIntegeLong_t  /(0[0-7]+)[lL]/   lexer classes { specialNumbers },  action{   } ;
 terminal PointFloatExponentImagNumber_t  /((([0-9]+)?\.[0-9]+)|[0-9]+\.)[jJ]/  action{   } ; 
 terminal DecimalIntegerImagNumber_t  /(([1-9][0-9]*)|0)[jJ]/  action{   } ;




 --Operators and others
 
 terminal Ellipsis_t  /\.\.\./  action{   } ;
 terminal Power_t  /\*\*/  action{   } ;
 terminal Power2_t  /\*\*/  action{   } ;
 terminal Tilde_t  /~/  action{   } ;
 terminal Plus_t  /\+/  action{   } ;
 terminal Dash_t  /\-/  action{   } ;
 terminal Multiply_  /\*/  action{   } ;
 terminal Divide_t  /\//  action{   } ;
 terminal DoubleDivide_t  /\/\//  action{   } ;
 terminal Modulus_t  /%/  action{   } ;
 terminal Colon_t  /:/  action{   } ;
 terminal Semicolon_t  /;/  action{   } ;
 terminal Comma_t  /,/  action{   } ;
 terminal OpenParen_t  /\(/  
 action
 {  
    parenLevel = parenLevel + 1 ; 
     
 }
 ;

 terminal CloseParen_t  /\)/ 
 action 
 {   
    parenLevel = parenLevel - 1 ; 
        
 }
 ;

 terminal OpenBracket_t  /\[/  
 action 
 {  
    parenLevel = parenLevel + 1 ; 
        
 }
 ;

 terminal CloseBracket_t  /\]/  
 action 
 {   
    parenLevel = parenLevel - 1 ; 
        
 }
 ;

 terminal Less_t  /</   action{   } ; 
 terminal Greater_t  />/   action{   } ;
 terminal DoubleEquals_t  /==/   action{   } ; 
 terminal GreaterEqual_t  />=/   action{   } ;
 terminal LessEqual_t  /<=/   action{   } ;
 terminal NotEqual_t  /<>/   action{   } ;
 terminal NotEqual2_t  /!=/   action{   } ;
 terminal Xor_t  /\^/   action{   } ;
 terminal Or_t  /\|/ lexer classes { keywds },  action{   } ;
 terminal And_t  /&/ lexer classes { keywds },  action{   } ;
 terminal RightShift_t  />>/ lexer classes { keywds },  action{   } ;
 terminal LeftShift_t  /<</ lexer classes { keywds },  action{   } ;
 terminal BackTick_t  /`/    action{   } ;
 terminal OpenCurly_t  /{/    action{   } ;
 terminal CloseCurly_t  /}/    action{   } ;
 terminal At_t  /@/    action{   } ;
 terminal Period_t  /\./    action{   } ;
 terminal Asterisk_t  /\*/    action{   } ;
 terminal Equals_t  /=/    action{   } ;









--Augmented Assignments

 terminal PlusEqual_t  /\+=/    action{   } ;
 terminal MinusEqual_t  /\-=/    action{   } ;
 terminal MultiplyEqual_t  /\*=/    action{   } ;
 terminal DivideEqual_t  /\/=/    action{   } ;
 terminal DoubleDivideEqual_t  /\/\/=/    action{   } ;
 terminal ModulusEqual_t  /%=/    action{   } ;
 terminal PowerEqual_t  /\*\*=/    action{   } ;
 terminal RightShiftEqual_t  />>=/    action{   } ;
 terminal LeftShiftEqual_t  /<<=/    action{   } ;
 terminal AndEqual_t  /&=/    action{   } ;
 terminal ExponentEqual_t  /\^=/    action{   } ;
 terminal OrEqual_t  /\|=/    action{   } ;





 --String


 terminal PrefixedShortString_t  /(u|U)(('([^'\n]|\\.|\\O[0-7])*')|("([^"\n]|\\.|\\O[0-7])*"))/    action{   } ;
 terminal PrefixedRawShortString_t  /(r|ur|R|UR|Ur|uR)(('([^']|\\.)*')|("([^"]|\\.)*"))/    action{   } ;
 terminal PrefixedLongString_t  /(u|U)(('''([^\\]|\\.|\\O[0-7])*''')|("""([^\\]|\\.|\\O[0-7])*"""))/    action{   } ;
 terminal PrefixedRawLongString_t  /(r|ur|R|UR|Ur|uR)(('''([^\\]|\\.)*''')|("""([^\\]|\\.)*"""))/    action{   } ;
 terminal ShortString_t  /(('([^'\n]|\\.|\\O[0-7])*')|("([^"\n]|\\.|\\O[0-7])*"))|(('([^']|\\.)*')|("([^"]|\\.)*"))/    action{   } ;
 terminal LongString_t  /('''([^']|'[^']|''[^'])*''')|("""([^"]|"[^"]|""[^"])*""")/    action{   } ;
 terminal LongStringFuncDocString_t  /(\n[\ \t]*)+('''([^']|'[^']|''[^'])*''')|("""([^"]|"[^"]|""[^"])*""")/    action{   } ;


 terminal Indent_t /(\n[\ \t]*)+/ 
 action
 { 

   --push into depths "stack"
   depths = removeExtraWhitespaceAndCalculateLength(lexeme) :: depths;
   --

 } ;

 terminal Dedent_t  /(\n[\ \t]*)+/ 
 action
 {    
   local attribute newDepth :: Integer = removeExtraWhitespaceAndCalculateLength(lexeme);

   --pop from depths "stack"
   depths = drop(1, depths);
   --

   pushToken(Dedent_t, removeExtraWhitespace(lexeme)) if (newDepth < head(depths));


 };



 terminal DedentRepair_t  /(\n[\ \t]*)+/ 
 action
 {  
   pushToken(Dedent_t, lexeme);
 };




-------------------------------------------------------------------------------


------------------Non Terminals------------------------------------------------




 nonterminal FileInput;
 nonterminal FileContents;
 nonterminal Suite;
 nonterminal StmtList;
 nonterminal Statements;
 nonterminal Statement;
 nonterminal CompoundStmt;
 nonterminal SimpleStmts;
 nonterminal SimpleStmt;
 nonterminal ExpressionStmt;
 nonterminal IfStmt;
 nonterminal ElsIf;
 nonterminal WhileStmt;
 nonterminal ForStmt;
 nonterminal TryStmt;
 nonterminal WithStmt;
 nonterminal Classdef;
 nonterminal TargetList;
 nonterminal Targets;
 nonterminal Target;
 nonterminal Try1Stmt;
 nonterminal Try2Stmt;
 nonterminal Except;
 nonterminal ExceptOptions;
 nonterminal ExpressionList;
 nonterminal Expressions;
 nonterminal Expression;
 nonterminal ConditionalExpression;
 nonterminal OrTest;
 nonterminal AndTest;
 nonterminal NotTest;
 nonterminal Comparison;
 nonterminal OrExpr;
 nonterminal XorExpr;
 nonterminal AndExpr;
 nonterminal ShiftExpr; 
 nonterminal AExpr;
 nonterminal MExpr;
 nonterminal UExpr;
 nonterminal Power;
 nonterminal Primary;
 nonterminal Atom;
 nonterminal Literal;
 nonterminal Int; 
 nonterminal LongInteger;
 nonterminal FloatNumber;
 nonterminal ImagNumber;
 nonterminal ExponentFloat; 
 nonterminal AttributeRef;
 nonterminal Slicing;
 nonterminal ExtendedSlicing;
 nonterminal SliceItem;
 nonterminal SliceOptions;
 nonterminal ProperSlice;
 nonterminal ShortSlice;
 nonterminal LongSlice;
 nonterminal LowerBound;
 nonterminal UpperBound;
 nonterminal Stride;
 nonterminal Call;
 nonterminal GenExprFor;
 nonterminal GenExprIter;
 nonterminal GenExprIf;
 nonterminal OldExpression;
 nonterminal OldLambdaForm;
 nonterminal LambdaForm;
 nonterminal Enclosure;
 nonterminal ParenthForm;
 nonterminal ListDisplay;
 nonterminal GeneratorExpression;
 nonterminal DictDisplay;
 nonterminal StringConversion;
 nonterminal YieldAtom; 
 nonterminal ListFor;
 nonterminal OldExpressionList;
 nonterminal OldExpressions;
 nonterminal OldExpressionsOptionalComma;
 nonterminal ListIter;
 nonterminal ListIf;
 nonterminal KeyDatumList;
 nonterminal KeyDatums;
 nonterminal KeyDatum;
 nonterminal ListComprehension;
 nonterminal ExpressionsNoCommaEnding;
 nonterminal AssertStmt;
 nonterminal AssignmentStmt;
 nonterminal Items;
 nonterminal YieldExpression;
 nonterminal AugmentedAssignmentStmt;
 nonterminal Augop;
 nonterminal PassStmt;
 nonterminal DelStmt;
 nonterminal PrintStmt;
 nonterminal ReturnStmt;
 nonterminal YieldStmt;
 nonterminal RaiseStmt;
 nonterminal BreakStmt;
 nonterminal ContinueStmt;
 nonterminal ImportStmt;
 nonterminal RestOfImport;
 nonterminal Module;
 nonterminal IdentifierAsName;
 nonterminal Periods;
 nonterminal IdentifiersPeriodSeperated ;
 nonterminal Name;
 nonterminal GlobalStmt;
 nonterminal IdentifiersCommaSeperated;
 nonterminal ExecStmt;
 nonterminal Classname;
 nonterminal Inheritance;
 nonterminal CompOperator;
 nonterminal Funcdef; 
 nonterminal ArgumentListOptionalAsteriskExpression;
 nonterminal ArgumentListOptionalPowerExpression;
 nonterminal KeywordArguments;
 nonterminal KeywordItem;
 nonterminal ArgumentList;
 nonterminal DefParameter;
 nonterminal DefParameters;
 nonterminal Parameter;
 nonterminal SubList;
 nonterminal SubListParameters;
 nonterminal Decorators;
 nonterminal SeveralDecorators;
 nonterminal Decorator;
 nonterminal Funcname;
 nonterminal ParameterList;
 nonterminal DottedName;
 nonterminal DottedNameOptionalPart;
 nonterminal DefList;
 nonterminal MoreModules;
 nonterminal ArgListAux;
 nonterminal StringLiteral;
 nonterminal StringLiteralPiece;
 nonterminal OrExprs;



-------------------------------------------------------------------------------



----------------------------Productions----------------------------------------








 concrete production fileInput
  a::FileInput ::= b::FileContents {}


 concrete productions a::FileContents
  | b::Newline_t c::FileContents {}
  | d::Statement e::FileContents {}
  | f::Newline_t {}
  | g::Statement {}
  



 concrete productions a::Suite 
  | b::StmtList c::Newline_t {}
  | d::StmtList e::DedentRepair_t {}
  | f::Indent_t g::Statements h::Dedent_t {}            
  

 concrete productions a::Statements 
  | b::Statement c::Statements {}
  | d::Statement {}
  
 
 concrete productions a::Statement
  |  b::StmtList c::Newline_t {}
  |  d::StmtList e::DedentRepair_t {}                                                                                     
  |  f::CompoundStmt  {}
  


 concrete production stmtList
  a::StmtList ::= b::SimpleStmts {}


 ---Simple Statements

 concrete productions a::SimpleStmts 
  | b::SimpleStmt c::Semicolon_t d::SimpleStmts {}
  | e::SimpleStmt f::Semicolon_t {}
  | g::SimpleStmt {}
  

 
 concrete productions a::SimpleStmt 
  | b::ExpressionStmt {}
  | c::AssertStmt {}
  | d::AssignmentStmt {}
  | e::AugmentedAssignmentStmt {}
  | f::PassStmt {}
  | g::DelStmt {}
  | h::PrintStmt {}
  | i::ReturnStmt {}
  | j::YieldStmt {}
  | k::RaiseStmt {}
  | l::BreakStmt {}
  | m::ContinueStmt {}
  | n::ImportStmt {}
  | o::GlobalStmt {}
  | p::ExecStmt {}


 concrete production expressionStmt
  a::ExpressionStmt ::= b::ExpressionList {}



 concrete productions a::ExecStmt 
  | b::ExecKwd_t c::OrExpr d::InKwd_t e::Expression f::Comma_t g::Expression {}
  | h::ExecKwd_t i::OrExpr j::InKwd_t k::Expression {}
  | l::ExecKwd_t m::OrExpr {}

 concrete production globalStmt
  a::GlobalStmt ::= b::GlobalKwd_t c::Identifier_t d::IdentifiersCommaSeperated {}


 concrete productions a::IdentifiersCommaSeperated 
  | b::Comma_t c::Identifier_t d::IdentifiersCommaSeperated {}
  | {}




 concrete productions a::ImportStmt 
  |  b::ImportKwd_t c::Module d::AsKwd_t e::Identifier_t f::MoreModules {}
  |  g::ImportKwd_t h::Module  i::MoreModules {}
  |  j::FromKwd_t k::Periods l::RestOfImport {} --Relative Module
  |  m::FromKwd_t n::Periods o::Module p::RestOfImport {} --Relative Module
  |  q::FromKwd_t r::Module s::RestOfImport {} --Relative Module
  |  t::FromKwd_t u::Module v::ImportKwd_t w::Asterisk_t {} --Regular Module
  

 concrete productions a::RestOfImport 
  | b::ImportKwd_t c::Identifier_t d::AsKwd_t e::Name f::IdentifierAsName {}
  | g::ImportKwd_t h::Identifier_t i::IdentifierAsName {}
  | j::ImportKwd_t k::OpenParen_t l::Identifier_t m::AsKwd_t n::Name o::IdentifierAsName p::CloseParen_t {} 
  | q::ImportKwd_t r::Identifier_t s::IdentifierAsName t::CloseParen_t {}
  | u::ImportKwd_t v::Identifier_t {}
  

 concrete productions a::MoreModules 
  | b::Comma_t c::Module d::AsKwd_t e::Identifier_t f::MoreModules {}
  | g::Comma_t h::Module i::MoreModules {}
  | {}


 concrete productions a::IdentifierAsName 
  | b::Comma_t c::Identifier_t d::AsKwd_t e::Name f::IdentifierAsName {}
  | g::Comma_t h::Identifier_t i::IdentifierAsName {}
  | j::Comma_t k::Identifier_t l::AsKwd_t m::Name {}
  | n::Comma_t o::Identifier_t {}
  | p::Comma_t {}
  

 concrete production module 
  a::Module ::= b::IdentifiersPeriodSeperated {}


 
 concrete productions a::IdentifiersPeriodSeperated 
  | b::Identifier_t c::Period_t d::IdentifiersPeriodSeperated {}
  | e::Identifier_t {}
  

 concrete productions a::Periods 
  | b::Period_t c::Periods {}
  | d::Period_t {}


 concrete production name
  a::Name ::= b::Identifier_t {}

 concrete production continueStmt
  a::ContinueStmt ::= b::ContinueKwd_t {}


 concrete production breakStmt
  a::BreakStmt ::= b::BreakKwd_t {}



 concrete productions a::RaiseStmt 
  | b::RaiseKwd_t c::Expression d::Comma_t e::Expression f::Comma_t g::Expression {}
  | h::RaiseKwd_t i::Expression j::Comma_t k::Expression {}
  | l::RaiseKwd_t m::Expression {}
  | n::RaiseKwd_t {}


 concrete production yieldStmt
  a::YieldStmt ::= b::YieldExpression {}



 concrete productions a::ReturnStmt 
  | b::ReturnKwd_t c::ExpressionList {}
  | d::ReturnKwd_t {}



  concrete productions a::PrintStmt 
  | b::PrintKwd_t c::ExpressionList {}
  | d::PrintKwd_t {}
  | e::PrintKwd_t f::RightShift_t g::Expression h::Comma_t i::ExpressionList {}
  | j::PrintKwd_t k::RightShift_t l::Expression {}


 concrete production delStmt
  a::DelStmt ::= b::DelKwd_t c::TargetList {}


 concrete production passStmt
  a::PassStmt ::= b::PassKwd_t {}


 ---Aug Assignment Statements

 
 concrete productions a::AugmentedAssignmentStmt 
  | b::Expression c::Augop d::ExpressionList {}
  | e::Expression f::Augop g::YieldExpression {}



 concrete productions a::Augop 
  | b::PlusEqual_t {}
  | c::MinusEqual_t {}
  | d::MultiplyEqual_t {}
  | e::DivideEqual_t {}
  | f::DoubleDivideEqual_t {} 
  | g::ModulusEqual_t {}
  | h::PowerEqual_t {}
  | i::RightShiftEqual_t {}
  | j::LeftShiftEqual_t {}
  | k::AndEqual_t {}
  | l::ExponentEqual_t {}
  | m::OrEqual_t {}
  


 --Assignment Statements

 concrete production assignmentStmt
  a::AssignmentStmt ::= b::Items {}


 concrete productions a::Items
  | b::ExpressionList c::Equals_t d::Items {}
  | e::ExpressionList f::Equals_t g::YieldExpression {}
  | h::ExpressionList i::Equals_t j::ExpressionList {}


 concrete production targetList
  a::TargetList ::= b::Targets {}

 
 concrete productions a::Targets 
  | b::Target c::Comma_t d::Targets {} 
  | e::Target f::Comma_t {}
  | g::Target {}


 concrete productions a::Target 
  | b::Identifier_t {}
  | c::OpenParen_t d::ExpressionList e::CloseParen_t {}
  | f::OpenBracket_t g::ExpressionList h::CloseBracket_t {}
  | i::AttributeRef {}
  | j::Slicing {}                                                                                            
  

 --END Statements


 --Expressions

 concrete production expressionList
  a::ExpressionList ::= b::Expressions {}


 
 concrete productions a::Expressions 
  | b::Expression c::Comma_t d::Expressions {}
  | e::Expression f::Comma_t {}
  | g::Expression {}


 concrete productions a::Expression 
  | b::ConditionalExpression {} --may reduce to an identifier_t in the simplest case
  | c::LambdaForm  {}


 concrete productions a::LambdaForm 
  | b::LambdaKwd_t c::ParameterList d::Colon_t e::Expression {}
  | f::LambdaKwd_t g::Colon_t h::Expression {}



 concrete productions a::YieldExpression 
  | b::YieldKwd_t c::ExpressionList {}
  | d::YieldKwd_t {}



 concrete productions a::AssertStmt 
  | b::AssertKwd_t c::Expression d::Comma_t e::Expression {}
  | f::AssertKwd_t g::Expression {}



 
 concrete productions a::ConditionalExpression 
  | b::OrTest c::IfKwd_t d::OrTest e::ElseKwd_t f::Expression {}
  | g::OrTest {}
   



 concrete productions a::OrTest 
  | b::AndTest {}
  | c::OrTest d::OrWordKwd_t e::AndTest {}



 concrete productions a::AndTest 
  | b::NotTest {} 
  | c::AndTest d::AndWordKwd_t e::NotTest {}
   



 concrete productions a::NotTest 
  | b::Comparison {}
  | c::NotWordKwd_t d::NotTest {}




 concrete productions a::Comparison 
  | b::OrExpr c::CompOperator d::Comparison {}
  | e::OrExpr {}




 concrete productions a::CompOperator 
  | b::Less_t {}
  | c::Greater_t {}
  | d::DoubleEquals_t {}
  | e::GreaterEqual_t {}
  | f::LessEqual_t {}
  | g::NotEqual_t {}
  | h::NotEqual2_t {}
  | i::IsKwd_t {}
  | j::InKwd_t {}
  | k::IsNotKwd_t {}
  | l::NotInKwd_t {}



 concrete productions a::AndExpr 
  | b::ShiftExpr {}
  | c::AndExpr d::And_t e::ShiftExpr {}


  


 concrete productions a::XorExpr 
  | b::AndExpr {} 
  | c::XorExpr d::Xor_t e::AndExpr {} 




 concrete productions a::OrExprs 
   | b::OrExpr c::Comma_t d::OrExprs {}
   | e::OrExpr f::Comma_t {}
   | g::OrExpr {}




 concrete productions a::OrExpr 
  | b::XorExpr {}
  | c::OrExpr d::Or_t e::XorExpr {}



 concrete productions a::ShiftExpr 
  | b::AExpr {}
  | c::ShiftExpr d::RightShift_t e::AExpr {}
  | f::ShiftExpr g::LeftShift_t h::AExpr {}



 concrete productions a::AExpr 
  | b::MExpr {} 
  | c::AExpr d::Plus_t e::MExpr {}
  | f::AExpr g::Dash_t h::MExpr {}


 


 concrete productions a::MExpr 
  | b::UExpr {} 
  | c::MExpr d::Multiply_ e::UExpr {}
  | f::MExpr g::Divide_t h::UExpr {} 
  | i::MExpr j::DoubleDivide_t k::UExpr {} 
  | l::MExpr m::Modulus_t n::UExpr {}
   



 concrete productions a::UExpr 
  | b::Power {} 
  | c::Dash_t d::UExpr {}
  | e::Plus_t f::UExpr {} 
  | g::Tilde_t h::UExpr {}


  
 concrete productions a::Power 
  | b::Primary {}
  | c::Primary d::Power_t e::UExpr {}



 concrete productions a::Primary 
  | b::Atom {}
  | c::AttributeRef {}
  | d::Slicing {}
  | e::Call {}  


 concrete productions a::Atom 
  | b::Identifier_t {}
  | c::Literal {}
  | d::Enclosure {}    






 concrete productions a::Enclosure 
  | b::ParenthForm {} 
  | c::ListDisplay {}
  | d::GeneratorExpression {}
  | e::DictDisplay {}
  | f::StringConversion {}
  | g::YieldAtom {}



 concrete productions a::ParenthForm 
  | b::OpenParen_t c::ExpressionList d::CloseParen_t {} 
  | e::OpenParen_t f::CloseParen_t {}





  concrete productions a::ListDisplay 
  | b::OpenBracket_t c::ExpressionList d::CloseBracket_t {}
  | e::OpenBracket_t f::ListComprehension g::CloseBracket_t {}
  | h::OpenBracket_t i::CloseBracket_t {}
  
 
  
 concrete production listComprehension
  a::ListComprehension ::= b::Expression c::ListFor {}

  
     

 

 concrete productions a::ListFor 
  | b::ForKwd_t c::OrExprs d::InKwd_t e::OldExpressionList f::ListIter {}
  | g::ForKwd_t h::OrExprs i::InKwd_t  j::OldExpressionList {}

         
  




 concrete production oldExpressionList
  a::OldExpressionList ::= b::OldExpression c::OldExpressions {}
 


 concrete productions a::OldExpressions 
  | b::Comma_t c::OldExpression d::OldExpressions {}
  | e::Comma_t f::OldExpression g::OldExpressionsOptionalComma {}
  | {}



 concrete production oldExpressionsOptionalComma 
   a::OldExpressionsOptionalComma ::=  b::Comma_t {}



 concrete productions a::ListIter 
  | b::ListFor {} 
  | c::ListIf {}




 concrete productions a::ListIf 
  | b::IfKwd_t c::OldExpression d::ListIter {}
  | e::IfKwd_t f::OldExpression {}
  
 

 concrete production generatorExpression
   a::GeneratorExpression ::= b::OpenParen_t c::Expression d::GenExprFor e::CloseParen_t {}





 
 concrete productions a::GenExprFor 
  | b::ForKwd_t c::OrExprs d::InKwd_t e::OrTest f::GenExprIter {}
  | g::ForKwd_t h::OrExprs i::InKwd_t j::OrTest {}
  
 




  

 concrete productions a::GenExprIter 
  | b::GenExprFor {}
  | c::GenExprIf {}






 concrete productions a::DictDisplay 
  | b::OpenCurly_t c::KeyDatumList d::CloseCurly_t {}
  | e::OpenCurly_t f::CloseCurly_t {}






 concrete production keyDatumList 
  a::KeyDatumList ::= b::KeyDatums {}






 concrete productions a::KeyDatums 
  | b::KeyDatum c::Comma_t d::KeyDatums {}
  | e::KeyDatum f::Comma_t {}
  | g::KeyDatum {}


 concrete production keyDatum
   a::KeyDatum ::= b::Expression c::Colon_t d::Expression {}



 
 concrete productions  a::ExpressionsNoCommaEnding 
  | b::Expression c::Comma_t d::ExpressionsNoCommaEnding {}
  | e::Expression {}




 concrete production stringConversion 
  a::StringConversion ::= b::BackTick_t c::ExpressionsNoCommaEnding d::BackTick_t {}



  
 concrete production yieldAtom
  a::YieldAtom ::= b::OpenParen_t c::YieldExpression d::CloseParen_t {}




 concrete production attributeRef
   a::AttributeRef ::= b::Primary c::Period_t d::Identifier_t {}





 concrete production slicing 
  a::Slicing ::= b::Primary c::OpenBracket_t d::SliceOptions e::CloseBracket_t {}


 --Slices


 concrete production sliceOptions
  a::SliceOptions ::= b::ExtendedSlicing {} --ExtendedSlicing 



 -- SimpleSlicing ::= ShortSlice






 concrete productions a::ExtendedSlicing 
  | b::SliceItem {}
  | c::SliceItem d::Comma_t e::ExtendedSlicing {}                                                               
  | f::SliceItem g::Comma_t {}         



 concrete productions a::SliceItem
  | b::ProperSlice {}
  | c::Expression {}                                                                                                    
  | d::Ellipsis_t {}
  


       

 concrete productions a::ProperSlice 
  | b::ShortSlice {}
  | c::LongSlice {}
                                                          
  


 

 concrete productions a::ShortSlice 
  | b::LowerBound c::Colon_t d::UpperBound {} 
  | e::LowerBound f::Colon_t {}
  | g::Colon_t h::UpperBound {}
  | i::Colon_t {}
   





 concrete productions a::LongSlice 
  | b::ShortSlice c::Colon_t d::Stride {} 
  | e::ShortSlice f::Colon_t {}






 concrete production lowerBound 
  a::LowerBound ::= b::Expression {}


 concrete production upperBound 
  a::UpperBound ::= b::Expression {}

 concrete production stride
  a::Stride ::= b::Expression {}



 concrete productions a::Call 
  | b::Primary c::OpenParen_t d::ArgumentList e::CloseParen_t {}
  | f::Primary g::OpenParen_t h::Expression i::GenExprFor j::CloseParen_t {}
  | k::Primary l::OpenParen_t m::CloseParen_t {}
  



 concrete productions a::GenExprIf 
  | b::IfKwd_t c::OldExpression d::GenExprIter {} 
  | e::IfKwd_t f::OldExpression {} 
  




 concrete productions a::OldExpression 
  | b::OrTest {}
  | c::OldLambdaForm {}



 concrete productions a::OldLambdaForm 
  | b::LambdaKwd_t c::ParameterList d::Colon_t e::OldExpression {}                                       
  | f::LambdaKwd_t g::Colon_t h::OldExpression {}


 concrete productions a::Literal 
  | b::StringLiteral {}                                                                                            
  | c::Int {}
  | d::LongInteger {}
  | e::FloatNumber {}
  | f::ImagNumber {}





 concrete productions a::StringLiteral 
  | b::StringLiteralPiece {}
  | c::StringLiteralPiece d::StringLiteralPiece {}



  

 concrete productions a::StringLiteralPiece 
  | b::PrefixedShortString_t {}
  | c::ShortString_t {}
  | d::PrefixedLongString_t {}
  | e::LongString_t {}
  | f::PrefixedRawShortString_t {}
  | g::PrefixedRawLongString_t {}
 
  


  

  

 concrete productions a::Int 
  | b::DecimalInteger_t {}
  | c::OctInteger_t {}
  | d::HexInteger_t {}


  
 concrete productions a::LongInteger 
  | b::DecimalIntegerLong_t {}
  | c::HexIntegerLong_t {}
  | d::OctIntegeLong_t {}
  



  concrete productions a::FloatNumber 
  | b::PointFloat_t {}
  | c::ExponentFloat  {}
  




  concrete productions a::ExponentFloat 
   | b::PointFloatExponent_t {}
   | c::PointIntExponent_t {}  
  

 concrete productions a::ImagNumber 
  | b::PointFloatExponentImagNumber_t {}
  | c::DecimalIntegerImagNumber_t {}
   

 --END Expressions


 --Compound Statements




 concrete productions a::CompoundStmt 
  | b::IfStmt {}
  | c::WhileStmt {}
  | d::ForStmt {}
  | e::TryStmt {}
  | f::WithStmt {}
  | g::Funcdef {}
  | h::Classdef {}
  




 concrete productions a::IfStmt 
  | b::IfKwd_t c::Expression d::Colon_t e::Suite f::ElsIf g::ElseKwd_t h::Colon_t i::Suite {}   --Note: The dangling else ambiguity is solved here with indentation
  | j::IfKwd_t k::Expression l::Colon_t m::Suite n::ElsIf {}
  


 concrete productions a::ElsIf 
  | b::ElifKwd_t c::Expression d::Colon_t e::Suite f::ElsIf {}
  | {}



 
 

 concrete productions a::WhileStmt 
  | b::WhileKwd_t c::Expression d::Colon_t e::Suite f::ElseKwd_t g::Colon_t h::Suite {} 
  | i::WhileKwd_t j::Expression k::Colon_t l::Suite {}


 concrete productions a::ForStmt 
  | b::ForKwd_t c::OrExprs d::InKwd_t e::ExpressionList f::Colon_t g::Suite h::ElseKwd_t i::Colon_t j::Suite {}
  | k::ForKwd_t l::OrExprs m::InKwd_t n::ExpressionList o::Colon_t p::Suite {}




 concrete productions a::TryStmt 
  | b::Try1Stmt {}
  | c::Try2Stmt {}





 concrete productions a::Try1Stmt 
  | b::TryKwd_t c::Colon_t d::Suite e::Except f::ElseKwd_t g::Colon_t h::Suite i::FinallyKwd_t j::Colon_t k::Suite {}
  | l::TryKwd_t m::Colon_t n::Suite o::Except p::ElseKwd_t q::Colon_t r::Suite {}
  | s::TryKwd_t t::Colon_t u::Suite v::Except w::FinallyKwd_t x::Colon_t y::Suite {}
  | z::TryKwd_t aa::Colon_t ab::Suite ac::Except {}



 concrete production try2Stmt
  b::Try2Stmt ::= c::TryKwd_t d::Colon_t e::Suite f::FinallyKwd_t g::Colon_t h::Suite {}




 concrete productions a::Except 
  | b::ExceptOptions c::Except {}
  | d::ExceptOptions {}



  
 concrete productions a::ExceptOptions
  | b::ExceptKwd_t c::Expression d::Comma_t e::Expression f::Colon_t g::Suite {}
  | h::ExceptKwd_t i::Expression j::Colon_t k::Suite {}
  | l::ExceptKwd_t m::Colon_t n::Suite {}
  

  


 concrete productions a::WithStmt 
  | b::WithKwd_t c::Expression d::AsKwd_t e::Expression f::Colon_t g::Suite {}
  | h::WithKwd_t i::Expression j::Colon_t k::Suite {} 
  


 concrete productions a::Classdef 
  | b::ClassKwd_t c::Classname d::Inheritance e::Colon_t f::Suite {}
  | g::ClassKwd_t h::Classname i::Colon_t j::Suite {}
  


 concrete productions a::Inheritance 
  | b::OpenParen_t c::ExpressionList d::CloseParen_t {}
  | e::OpenParen_t f::CloseParen_t {}


 concrete production classname
  a::Classname ::= b::Identifier_t{}





 concrete productions a::Funcdef 
  | b::Decorators c::DefKwd_t d::Funcname e::OpenParen_t f::ParameterList g::CloseParen_t h::Colon_t i::Suite {}
  | j::Decorators k::DefKwd_t l::Funcname m::OpenParen_t n::CloseParen_t o::Colon_t p::Suite {}
  | q::DefKwd_t r::Funcname s::OpenParen_t t::ParameterList u::CloseParen_t v::Colon_t w::Suite {}
  | x::DefKwd_t y::Funcname z::OpenParen_t aa::CloseParen_t ab::Colon_t ac::Suite {}
  | ad::Decorators ae::DefKwd_t af::Funcname ag::OpenParen_t ah::ParameterList ai::CloseParen_t aj::Colon_t ak::LongStringFuncDocString_t al::Suite {}
  | am::Decorators an::DefKwd_t ao::Funcname ap::OpenParen_t aq::CloseParen_t ar::Colon_t hello::LongStringFuncDocString_t at::Suite {}
  | au::DefKwd_t av::Funcname aw::OpenParen_t ax::ParameterList ay::CloseParen_t az::Colon_t ba::LongStringFuncDocString_t b::Suite {}
  | bc::DefKwd_t bd::Funcname be::OpenParen_t bf::CloseParen_t bg::Colon_t bh::LongStringFuncDocString_t bi::Suite {}
  
 concrete production  decorators
  a::Decorators ::= b::SeveralDecorators {}
 
 concrete productions a::SeveralDecorators 
  | b::Decorator c::Decorators {}
  | d::Decorator {}




 concrete productions a::Decorator 
  | b::At_t c::DottedName d::OpenParen_t e::ArgumentList f::CloseParen_t g::Newline_t {}  
  | h::At_t i::DottedName j::OpenParen_t k::CloseParen_t l::Newline_t {}
  | m::At_t n::DottedName o::Newline_t  {}
  

 concrete production dottedName
  a::DottedName ::= b::Identifier_t c::DottedNameOptionalPart {}

 concrete productions a::DottedNameOptionalPart 
  | b::Period_t c::Identifier_t d::DottedNameOptionalPart {}
  | {}

 concrete production funcname 
  a::Funcname ::= b::Identifier_t {}




 concrete productions a::DefParameters 
  | b::DefParameter c::Comma_t d::DefParameters {}
  | e::Asterisk_t f::Identifier_t g::Comma_t h::Power_t i::Identifier_t {}
  | j::Asterisk_t k::Identifier_t {}
  | l::Power_t m::Identifier_t {}
  | n::DefParameter {}
  | o::DefParameter p::Comma_t {}
  

 concrete productions a::ParameterList 
  | b::DefParameter c::Comma_t d::DefParameters {}
  | e::DefParameter f::Comma_t {}
  | g::DefParameter {}
  | h::Asterisk_t i::Identifier_t j::Comma_t k::Power_t l::Identifier_t {}
  | m::Asterisk_t n::Identifier_t {}
  | o::Power_t p::Identifier_t {}
  


 concrete productions a::DefParameter 
  | b::Parameter c::Equals_t d::Expression {}
  | e::Parameter {}

 concrete productions a::Parameter 
  | b::Identifier_t {} 
  | c::OpenParen_t d::SubList e::CloseParen_t {}


 concrete production subList 
  a::SubList ::= b::SubListParameters {}





 concrete productions a::SubListParameters 
  | b::Parameter c::Comma_t d::SubListParameters {} 
  | e::Parameter f::Comma_t {}
  | g::Parameter {}



 concrete productions a::ArgumentList 
  | b::Expression c::ArgListAux {}
  | d::KeywordArguments {}
  | e::ArgumentListOptionalAsteriskExpression {}
  | f::Asterisk_t g::Expression h::ArgumentListOptionalPowerExpression {}
  | i::Power_t j::Expression {}


  
 concrete productions a::ArgListAux 
  |  b::Comma_t c::Expression d::ArgListAux {}
  |  e::Comma_t f::Identifier_t g::Equals_t h::Expression i::DefList {}
  |  j::Comma_t k::Asterisk_t l::Expression m::ArgumentListOptionalAsteriskExpression {}
  |  n::Comma_t o::Power_t p::Expression {}
  |  q::Comma_t {}
  | {}
  
 concrete productions a::DefList 
  |  b::Comma_t c::Identifier_t d::Equals_t e::Expression f::DefList {}
  |  g::Comma_t  h::Asterisk_t i::Expression j::ArgumentListOptionalAsteriskExpression {}
  |  k::Comma_t l::Power_t m::Expression {}
  |  n::Comma_t {}
  | {}
   
 
  
 concrete production keywordArguments 
  b::KeywordArguments ::= c::KeywordItem d::DefList {}
 
 concrete production keywordItem 
  a::KeywordItem ::= b::Identifier_t c::Equals_t d::Expression {}


 concrete productions a::ArgumentListOptionalAsteriskExpression 
  | b::Comma_t c::Asterisk_t d::Expression e::ArgumentListOptionalPowerExpression {}
  | f::Comma_t g::Power_t h::Expression {}
  | i::Comma_t {}
  
 concrete productions a::ArgumentListOptionalPowerExpression 
  | b::Comma_t c::Power_t d::Expression {}
  | e::Comma_t {} 
  | {}



-------------------------------------------------------------------------------

















