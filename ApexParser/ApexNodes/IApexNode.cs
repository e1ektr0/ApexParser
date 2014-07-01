using System;
using System.Collections.Generic;
using ApexParser.Scopes;

namespace ApexParser.ApexNodes
{
    public interface IApexNode
    {
        void Add(IApexNode node);
        void AddRage<T>(IList<T> nodes) where T : IApexNode;
    }

    //public interface IScopedObject
    //{
    //    Scope Scope { get; set; }
    //}

    //public interface IMember:IIdent
    //{

    //}

    public interface IModifier
    {
        List<Modifier> Modifiers { get; set; }
    }

    public interface IIdent
    {
        string Ident { get; }
    }

    public class BaseScopedClass : BaseApexNode
    {
    //    private Scope _scope;

    //    public Scope Scope
    //    {
    //        get
    //        {
    //            return _scope;
    //        }
    //        set
    //        {
    //            if(_scope!=null)
    //                throw new NotImplementedException();
    //            _scope = value;
    //            foreach (var apexNode in Nodes)
    //            {
    //                FixScope(apexNode);
    //            }
    //        }
    //    }

    }

    public class ApexClassNode : BaseScopedClass, IModifier, IIdent
    {
        public ApexClassNode(string ident, List<Modifier> modifierList)
        {
            Ident = ident;
            Modifiers = modifierList;
        }

        public string Ident { get; private set; }

        public List<ApexType> Extends { get; set; }

        public List<ApexType> Generics { get; set; }

        public List<Modifier> Modifiers { get; set; }
    }
    public class ApexInterfaceNode : BaseScopedClass, IModifier, IIdent
    {

        public ApexInterfaceNode(string ident, List<Modifier> modifierList)
        {
            Ident = ident;
            Modifiers = modifierList;
        }

        public List<ApexType> Generics { get; set; }

        public List<ApexType> Extends { get; set; }
        public List<Modifier> Modifiers { get; set; }
        public string Ident { get; private set; }
    }
    public class EnumBlock : BaseApexNode
    {
        public readonly List<string> Idents = new List<string>();
        internal void AddName(string enumValue)
        {
            Idents.Add(enumValue);
        }
    }

    public class Block : BaseScopedClass
    {

    }

    public class ApexEnum : BaseApexNode, IModifier, IIdent
    {
        //private EnumScope enumScope;
        private EnumBlock enumTopLevelScope13;

        public ApexEnum(string ident, EnumBlock enumTopLevelScope13,  List<Modifier> modifierList)
        {
            this.Ident = ident;
            this.enumTopLevelScope13 = enumTopLevelScope13;
            //this.enumScope = enumScope;
            //enumScope.AddMembers(enumTopLevelScope13.Idents);
            this.Modifiers = modifierList;
        }

        public List<Modifier> Modifiers { get; set; }
        //public Scope Scope { get; set; }
        public string Ident { get; private set; }
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
        private readonly ApexType _type;
        private readonly List<ApexField> _variableDeclaratorList;

        public LocalVariableDeclaration()
        {
        }

        public LocalVariableDeclaration(ApexType type, List<ApexField> variableDeclaratorList)
        {
            _type = type;
            _variableDeclaratorList = variableDeclaratorList;
        }

        public ApexType Type
        {
            get { return _type; }
        }

        public List<ApexField> VariableDeclaratorList
        {
            get { return _variableDeclaratorList; }
        }
    }

    public class BrokenExpression : BaseApexNode
    {
    }

    public enum AcessorType
    {
        Get, Set
    }

    public class Acessor : BaseScopedClass
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
