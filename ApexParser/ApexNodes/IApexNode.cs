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

    public interface IScopedObject
    {
        Scope Scope { get; set; }
    }

    public interface IModifier
    {
        List<Modifier> Modifiers { get; set; }
    }

    public interface IIdent
    {
        string Ident { get; }
    }

    public class BaseScopedClass : BaseApexNode, IScopedObject
    {
        private Scope _scope;

        public Scope Scope
        {
            get
            {
                return _scope;
            }
            set
            {
                if(_scope!=null)
                    throw new NotImplementedException();
                _scope = value;
                foreach (var apexNode in Nodes)
                {
                    FixScope(apexNode);
                }
            }
        }

        public override void Add(IApexNode node)
        {
            base.Add(node);
            FixScope(node);
        }

        public override void AddRage<T>(IList<T> nodes)
        {
            base.AddRage(nodes);
            foreach (var apexNode in Nodes)
                FixScope(apexNode);
        }

        private void FixScope(IApexNode node)
        {
            if (Scope == null)
                return;
            if (node is IScopedObject)
            {
                ScopeFactory.Instance.FixScope(node, Scope);
            }
            AddMembers(node);
        }

        private void AddMembers(IApexNode node)
        {
            var modifier = node as IModifier;
            if (modifier == null)
                return;
            var ident = node as IIdent;
            if (ident == null)
                return;
            Scope.AddMemeber(modifier.Modifiers, ident.Ident, node);
        }
    }

    public class ApexClassNode : BaseScopedClass, IModifier, IIdent
    {
        public ApexClassNode(string ident, ClassScope classScope, List<Modifier> modifierList)
        {
            Ident = ident;
            Scope = classScope;
            Modifiers = modifierList;
            var rootScope = classScope.ParentScope as RootScope;
            if(rootScope!=null)
                rootScope.AddMemeber(modifierList, ident, this);
        }

        public string Ident { get; private set; }

        public List<ApexType> Extends { get; set; }

        public List<ApexType> Generics { get; set; }

        public List<Modifier> Modifiers { get; set; }
    }
    public class ApexInterfaceNode : BaseScopedClass, IModifier, IIdent
    {

        public ApexInterfaceNode(string ident, InterfaceScope interfaceScope, List<Modifier> modifierList)
        {
            Ident = ident;
            Scope = interfaceScope;
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

    public class ApexEnum : BaseApexNode, IModifier, IScopedObject, IIdent
    {
        private EnumScope enumScope;
        private EnumBlock enumTopLevelScope13;

        public ApexEnum(string ident, EnumBlock enumTopLevelScope13, EnumScope enumScope, List<Modifier> modifierList)
        {
            this.Ident = ident;
            this.enumTopLevelScope13 = enumTopLevelScope13;
            this.enumScope = enumScope;
            enumScope.AddMembers(enumTopLevelScope13.Idents);
            this.Modifiers = modifierList;
        }

        public List<Modifier> Modifiers { get; set; }
        public Scope Scope { get; set; }
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
