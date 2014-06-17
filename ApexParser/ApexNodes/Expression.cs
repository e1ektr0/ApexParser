namespace ApexParser.ApexNodes
{
    public class Expression : BaseApexNode
    {

    }

    public class DoubleExpression : Expression
    {
        private readonly Expression _a;
        private readonly Expression _b;

        public DoubleExpression(IApexNode a, IApexNode b)
        {
            _a = a as Expression;
            _b = b as Expression;
        }
    }

    public abstract class BynaryOperationExpression : DoubleExpression
    {
        public BynaryOperationExpression(IApexNode a, IApexNode b) : base(a, b)
        {
        }
    }

    public class BynaryOperationWithBooleanResultExpression : BynaryOperationExpression
    {
        public BynaryOperationWithBooleanResultExpression(IApexNode a, IApexNode b)
            : base(a, b)
        {
        }
    }

    public class BitOperationExpression : DoubleExpression
    {
        public BitOperationExpression(IApexNode a, IApexNode b) : base(a, b)
        {
        }
    }

    public class MathExpression : DoubleExpression
    {
        public MathExpression(IApexNode a, IApexNode b) : base(a, b)
        {
        }
    }
   
    public class TernarIfExpression : LogicalDoubleExpression
    {
        private readonly Expression _ifExpression;

        public TernarIfExpression(IApexNode ifExpression, IApexNode a, IApexNode b)
            : base(a, b)
        {
            _ifExpression = ifExpression as Expression;
        }
    }

    public class LogicalDoubleExpression : DoubleExpression
    {
        public LogicalDoubleExpression(IApexNode a, IApexNode b) : base(a, b)
        {
        }
    }

    public class AssigmentExpression : DoubleExpression
    {
        public AssigmentExpression(IApexNode a, IApexNode b) : base(a, b)
        {
        }
    }

    public class CastExpression : Expression
    {
        private readonly ApexType _type;
        private readonly Expression _sourExpression;

        public CastExpression(ApexType type, IApexNode sourExpression)
        {
            _type = type;
            _sourExpression = sourExpression as Expression;
        }
    } 
    public class InstanceOf : Expression
    {
        private readonly ApexType _type;
        private readonly Expression _sourExpression;

        public InstanceOf(ApexType type, IApexNode sourExpression)
        {
            _type = type;
            _sourExpression = sourExpression as Expression;
        }
    }
}