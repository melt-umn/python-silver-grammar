grammar edu:umn:cs:melt:python ;

{--
 - Declare a parser, called 'parse', using the concrete syntax in the
 - 'edu:umn:cs:melt:python' grammar.
 -
 - parse :: ( ParseResult<FileInput> ::= String String )
 - (The arguments are "string to parse", "file name to refer to this
 -  string as coming from".)
 -}
parser parse :: FileInput  { edu:umn:cs:melt:python ; }

{--
 - main :: Function( IO ::= String IO ) is the entry point for Silver programs.
 -
 - Note that 'IO' is something that should be considered 'the state of the 
 - world' and each value used only once.
 -}
function main 
IOVal<Integer> ::= args::[String] io_in::IOToken
{
  local attribute filename::String ;
  filename = head(args) ;

  production attribute isF :: IOVal<Boolean>;
  isF = isFileT( filename, io_in);

  production attribute text :: IOVal<String>;
  text = readFileT(filename, isF.io);

  local attribute result :: ParseResult<FileInput>;
  result = parse(text.iovalue, filename);

  local attribute r :: FileInput ;
  r = result.parseTree ;

  return if   ! isF.iovalue 
         then error ("\n\nFile \"" ++ filename ++ "\" not found.\n")
         else
         if   ! result.parseSuccess 
         then ioval (
                 printT("Encountered a parse error in file \"" ++ filename ++ 
                       "\":\n" ++ result.parseErrors ++ "\n", text.io) ,
                 1 ) 
         else ioval (
                printT( "Program \"" ++ filename ++ "\" parsed correctly.\n" ,
                       text.io ) ,
                0 ) ;
}
