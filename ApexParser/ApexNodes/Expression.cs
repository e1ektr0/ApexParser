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
    //primory expression:

    public class ContantExpression : Expression
    {
        private readonly string _typeIdent;
        private readonly string _value;

        public ContantExpression(string typeIdent, string value)
        {
            _typeIdent = typeIdent;
            _value = value;
        }
    }

    public class ThisExpression : Expression
    {

    }

    public class SuperExpression : Expression
    {

    }

    public class IdentExpression : Expression
    {
        private readonly string _ident;

        public IdentExpression(string ident)
        {
            _ident = ident;
        }
    }

    public class MethodCallExpression:Expression
    {
        private readonly IApexNode _methodPrimoryExpression;

        public MethodCallExpression(IApexNode methodPrimoryExpression)
        {
            _methodPrimoryExpression = methodPrimoryExpression;
        }

        public System.Collections.Generic.List<IApexNode> Arguments { get; set; }

        public System.Collections.Generic.List<ApexType> Generic { get; set; }
    }

    public enum DotScope
    {
        Ident,
        This, Super, Class
    }

    public class DotExpression : Expression
    {
        private string _methodName;
        private IApexNode _leftExpression;
        private DotScope dotScope;
        private IApexNode innerNewExpression52;

        public DotExpression(string methodName, IApexNode leftExpression)
        {
            this._methodName = methodName;
            this.dotScope = DotScope.Ident;
            this._leftExpression = leftExpression;
        }

        public DotExpression(DotScope dotScope, IApexNode leftExpression)
        {
            this.dotScope = dotScope;
            this._leftExpression = leftExpression;
        }

        public DotExpression(IApexNode innerNewExpression52, IApexNode leftExpression)
        {
            this.innerNewExpression52 = innerNewExpression52;
            this._leftExpression = leftExpression;
        }

    }
}