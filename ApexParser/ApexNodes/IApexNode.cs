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

    }


    public class Statement : BaseApexNode
    {

    }

    public class Block : BaseApexNode
    {

    }

    public class LocalVariableDeclaration : BaseApexNode
    {
        public LocalVariableDeclaration()
        {
        }

        public LocalVariableDeclaration(ApexType type30, List<ApexField> variableDeclaratorList31)
        {

        }
    }

    public class Expression : BaseApexNode
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
