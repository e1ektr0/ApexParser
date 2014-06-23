using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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
}
