﻿using System;
using System.IO;
using System.Reflection;
using Antlr.Runtime;
using Antlr.Runtime.Tree;
using ApexParser.ApexNodes;

namespace DebugConsole
{
    static class JavaParserExtension
    {
        public static AstParserRuleReturnScope<CommonTree, IToken> JavaSource(this JavaParser parser)
        {
            var type = parser.GetType();
            var methodInfos = type.GetMethod("javaSource", BindingFlags.NonPublic | BindingFlags.Instance);
            var method = methodInfos;
            return (AstParserRuleReturnScope<CommonTree, IToken>)method.Invoke(parser, new object[0]);
        }
        public static IApexNode JavaSource(this JavaTreeParser parser)
        {
            var type = parser.GetType();
            var methodInfos = type.GetMethod("javaSource", BindingFlags.NonPublic | BindingFlags.Instance);
            var method = methodInfos;
            return (IApexNode)method.Invoke(parser, new object[0]);
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
            var nodes = new CommonTreeNodeStream(tree);
            var xs = new JavaTreeParser(nodes);
            xs.enableErrorMessageCollection(true);
            var rootNode = xs.JavaSource();
            if (!parser.hasErrors() && !xs.hasErrors())
            {
            }
            else
            {
                foreach (var message in parser.getMessages())
                {
                    Console.WriteLine(message);
                }
                foreach (var message in xs.getMessages())
                {
                    Console.WriteLine(message);
                }
                throw new NotImplementedException();
            }
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
            parser.Load(@"java.test");
            parser.Load(@"Examples\types.test");
            parser.Load(@"Examples\methods.test");
            parser.Load(@"Examples\block.test");
            parser.Load(@"Examples\statements.test");
        }
    }
}
