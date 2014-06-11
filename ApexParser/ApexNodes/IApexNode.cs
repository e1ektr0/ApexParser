using System.Collections.Generic;

namespace ApexParser.ApexNodes
{
    public interface IApexNode
    {
        void Add(IApexNode node);
        void AddRage(List<IApexNode> nodes);
    }

    public abstract class BaseApexNode : IApexNode
    {
        public readonly List<IApexNode> Nodes = new List<IApexNode>();

        public virtual void Add(IApexNode node)
        {
            Nodes.Add(node);
        }

        public virtual void AddRage(List<IApexNode> nodes)
        {
            Nodes.AddRange(nodes);
        }
    }

    public class ApexType : BaseApexNode
    {
        private readonly string _ident;

        public ApexType(string ident)
        {
            _ident = ident;
        }
    }

    public class ApexFieldList : BaseApexNode
    {
        public ApexFieldList(ApexType type9, List<Modifier> modifierList10, List<ApexField> variableDeclaratorList11)
        {
                
        }

        public List<ApexField> ApexFields { get; set; }
     
    }

    public class ApexProperty : BaseApexNode
    {
        private readonly string _text;
        private readonly ApexType _type13;
        private readonly List<Modifier> _modifierList14;

        public ApexProperty(string text, ApexType type13, List<Modifier> modifierList14)
        {
            _text = text;
            _type13 = type13;
            _modifierList14 = modifierList14;
        }
    }

    public class ApexConstructor : BaseApexNode
    {
        private readonly List<Modifier> _modifierList12;

        public ApexConstructor(List<Modifier> modifierList12)
        {
            _modifierList12 = modifierList12;
        }
    }

    public class ApexField
    {
        public ApexField(string text)
        {
            
        }

        public bool IsArray { get; set; }
    }

    public class ApexMethod : BaseApexNode
    {
        private readonly List<Modifier> _modifierList8;
        private readonly string _text;
        private readonly List<Modifier> _modifierList5;
        private readonly ApexType _type6;

        public ApexMethod(string text, List<Modifier> modifierList5, ApexType type6)
        {
            _text = text;
            _modifierList5 = modifierList5;
            _type6 = type6;
        }

        public ApexMethod(string text, List<Modifier> modifierList8)
        {
            _text = text;
            _modifierList8 = modifierList8;
        }
    }

    public enum Modifier
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

    public class ApexClassNode : BaseApexNode
    {
        
    }

   
    public class Statement : BaseApexNode
    {

    }

    public class Block : BaseApexNode
    {

    }

    public class Expression : BaseApexNode
    {
        
    }

    enum AcessorType
    {
        
    }
    public class Acessor
    {

    }

}
