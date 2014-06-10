using System;

namespace ApexParser.ApexNodes
{

    public class ApexScope
    {
        private ApexType Resolve(string inden)
        {
            throw new NotImplementedException();
        }
    }

    public interface IApexNode
    {
        ApexType Evaluate();
    }

    public class ApexType
    {

    }

    internal enum Modifier
    {
        Public,
        Protected,
        Private,
        Static,
        Abstract,
        Override,
        Virtual,
        Global,
        TestMethod
    }

    public class ApexClassNode : IApexNode
    {
        public ApexType Evaluate()
        {
            throw new NotImplementedException();
        }
    }
}
