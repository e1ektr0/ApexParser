using System.Collections.Generic;

namespace ApexParser.ApexNodes
{
    public interface IApexNode
    {
        void Add(IApexNode node);
        void AddRage<T>(List<T> nodes) where T : IApexNode;

    }

    public class ApexClassNode : BaseApexNode
    {
        private string p;

        public ApexClassNode(string p)
        {
            // TODO: Complete member initialization
            this.p = p;
        }


        public List<ApexType> Extends { get; set; }

        public List<ApexType> Generics { get; set; }
    }
    public class ApexInterfaceNode : BaseApexNode
    {
        private string p;

        public ApexInterfaceNode(string p)
        {
            // TODO: Complete member initialization
            this.p = p;
        }

        public List<ApexType> Generics { get; set; }

        public List<ApexType> Extends { get; set; }
    }
    public class EnumBlock : BaseApexNode
    {

        internal void AddName(string enumConstant18)
        {
            throw new System.NotImplementedException();
        }
    }

    public class Block : BaseApexNode
    {

    }
    public class ApexEnum : BaseApexNode
    {
        private string p;
        private EnumBlock enumTopLevelScope11;

        public ApexEnum(string p, EnumBlock enumTopLevelScope11)
        {
            // TODO: Complete member initialization
            this.p = p;
            this.enumTopLevelScope11 = enumTopLevelScope11;
        }

    }

    public class SignatureParam : BaseApexNode
    {
        private ApexType type53;
        private ApexField variableDeclaratorId54;

        public SignatureParam(ApexType type53, ApexField variableDeclaratorId54)
        {
            // TODO: Complete member initialization
            this.type53 = type53;
            this.variableDeclaratorId54 = variableDeclaratorId54;
        }
    }

    public class LocalVariableDeclaration : BaseApexNode
    {
        private readonly ApexType _type30;
        private readonly List<ApexField> _variableDeclaratorList31;

        public LocalVariableDeclaration()
        {
        }

        public LocalVariableDeclaration(ApexType type30, List<ApexField> variableDeclaratorList31)
        {
            _type30 = type30;
            _variableDeclaratorList31 = variableDeclaratorList31;
        }
    }

    public class BrokenExpression : BaseApexNode
    {
    }

    public enum AcessorType
    {
        Get, Set
    }

    public class Acessor : BaseApexNode
    {
        private readonly AcessorType _get;
        private readonly IApexNode _getBlock;
        private readonly string _getRule17;


        public Acessor(AcessorType get, IApexNode getBlock, string getRule17)
        {
            _get = get;
            _getBlock = getBlock;
            _getRule17 = getRule17;
        }

        public Acessor(AcessorType get, string getRule17)
        {
            _get = get;
            _getRule17 = getRule17;
        }
    }



}
