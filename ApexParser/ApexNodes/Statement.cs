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
}
