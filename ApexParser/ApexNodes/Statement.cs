using System.Collections.Generic;

namespace ApexParser.ApexNodes
{
    public class Statement : BaseApexNode
    {

    }

    public class IfStatement : Statement
    {

        public IApexNode BoolExpression { get; set; }

        public IApexNode TrueStatement { get; set; }

        public IApexNode ElseStatement { get; set; }
    }

    public class ForInit : Statement
    {
        private LocalVariableDeclaration localVariableDeclaration51;

        public ForInit(LocalVariableDeclaration localVariableDeclaration51)
        {
            // TODO: Complete member initialization
            this.localVariableDeclaration51 = localVariableDeclaration51;
        }

        public ForInit()
        {
            // TODO: Complete member initialization
        }

    }
    public class ForStatement : Statement
    {

        public ForInit Init { get; set; }

        public IApexNode Condition { get; set; }

        public List<IApexNode> Update { get; set; }
        public IApexNode Statement { get; set; }
    }

    public class CatchBlock : BaseApexNode
    {
        private IApexNode block57;

        public CatchBlock(IApexNode block57)
        {
            // TODO: Complete member initialization
            this.block57 = block57;
        }

    }
    public class WhileStatement : Statement {
        private IApexNode parenthesizedExpression53;
        private IApexNode whileInnerStatement;

        public WhileStatement(IApexNode parenthesizedExpression53, IApexNode whileInnerStatement)
        {
            // TODO: Complete member initialization
            this.parenthesizedExpression53 = parenthesizedExpression53;
            this.whileInnerStatement = whileInnerStatement;
        }
    }
    public class ForEachStatement : Statement {
        private ApexType type50;
        private string p;
        private IApexNode expression52;
        private IApexNode foreachStatementInner;

        public ForEachStatement(ApexType type50, string p, IApexNode expression52, IApexNode foreachStatementInner)
        {
            // TODO: Complete member initialization
            this.type50 = type50;
            this.p = p;
            this.expression52 = expression52;
            this.foreachStatementInner = foreachStatementInner;
        }
    }
    public class TryStatemnt : Statement { public IApexNode Try { get; set; }
    public List<CatchBlock> Catches { get; set; }

    public IApexNode Finaly { get; set; }
    }
    public class DoStatement : Statement {
        private IApexNode parenthesizedExpression54;
        private IApexNode doInnerStatemnt;

        public DoStatement(IApexNode parenthesizedExpression54, IApexNode doInnerStatemnt)
        {
            // TODO: Complete member initialization
            this.parenthesizedExpression54 = parenthesizedExpression54;
            this.doInnerStatemnt = doInnerStatemnt;
        }
    }
}
