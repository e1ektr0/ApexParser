using Antlr.Runtime;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace ParserTests
{
    [TestClass]
    public class LexerTests
    {
        [TestMethod]
        public void TestHelloWorld()
        {
            var stream = new ANTLRStringStream("public class HelloWorld { public static void main(String[] args) { System.out.println(\"Здравствуй, мир!\"); }}");
            var lexer = new JavaLexer(stream, new RecognizerSharedState { errorRecovery = true });
            var token = lexer.NextToken();
            while (token.Type != JavaLexer.EOF)
            {

            }

        }
        [TestMethod]
        public void TestGetSet()
        {

        }
    }
}
