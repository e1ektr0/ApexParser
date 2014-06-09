using System;
using System.IO;
using System.Reflection;
using Antlr.Runtime;
using Antlr.Runtime.Tree;

namespace DebugConsole
{
    static class JavaParserExtension
    {
        public static AstParserRuleReturnScope<CommonTree, IToken> JavaSource(this JavaParser parser)
        {
            var type = parser.GetType();
            //var x = parser.javaSource();
            var methodInfos = type.GetMethod("javaSource", BindingFlags.NonPublic | BindingFlags.Instance);
            var method = methodInfos;
            return (AstParserRuleReturnScope<CommonTree, IToken>)method.Invoke(parser, new object[0]);
        }
    }

    public class ApaexParser
    {
        public void Load(string path)
        {
            var tokens = new CommonTokenStream(GetLexer(path));
            var parser = new JavaParser(tokens);
            parser.enableErrorMessageCollection(true);
            var tree = parser.JavaSource().Tree;
            if (!parser.hasErrors())
                return;

            foreach (var message in parser.getMessages())
            {
                Console.WriteLine(message);
            }
            Console.ReadKey();
        }

        private static JavaLexer GetLexer(string path)
        {
            var stream = new ANTLRStringStream(File.ReadAllText(path).ToLower());
            var lexer = new JavaLexer(stream, new RecognizerSharedState { errorRecovery = true });
            return lexer;
        }
    }

    class Program
    {
        static void Main()
        {
            var parser = new ApaexParser();
            ////parser.Load(@"Examples\ActualsReportingBatch.cls");
            parser.Load(@"java.test");
            //return;
            foreach (var file in Directory.GetFiles("MEP"))
            {
                Console.WriteLine(file);
                parser.Load(file);
            }
        }
      
    }
}
