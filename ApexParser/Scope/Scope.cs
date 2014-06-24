using System;
using System.Collections.Generic;
using ApexParser.ApexNodes;

namespace ApexParser.Scopes
{
    public class ScopeFactory
    {
        private RootScope _rootScope;
        private static ScopeFactory _scopeFactory;

        public static ScopeFactory Instance
        {
            get
            {
                return _scopeFactory ?? (_scopeFactory = new ScopeFactory());
            }
        }

        public RootScope GetRootScope()
        {
            return _rootScope ?? (_rootScope = new RootScope());
        }

        public ClassScope CreateClassScope(Scope parentScope = null)
        {
            if (parentScope == null)
                parentScope = GetRootScope();

            var classScope = new ClassScope(parentScope);

            return classScope;
        }
        public InterfaceScope CreateInterfaceScope(Scope parentScope = null)
        {
            if (parentScope == null)
                parentScope = GetRootScope();

            var classScope = new InterfaceScope(parentScope);

            return classScope;
        }

        public EnumScope CreateEnumScope(Scope parentScope = null)
        {
            if (parentScope == null)
                parentScope = GetRootScope();

            var classScope = new EnumScope(parentScope);

            return classScope;
        }

        public Scope CreateMethodScope(Scope parentScope)
        {
            return new BlockScope(parentScope);
        }

        public Scope CreateStatementScope(Scope parentScope)
        {
            return new BlockScope(parentScope);
        }

        public Scope CreatePropertyScope(Scope parentScope)
        {
            return new BlockScope(parentScope);
        }

        public Scope CreateAcessorScope(Scope parentScope)
        {
            return new BlockScope(parentScope);
        }

        public void FixScope(IApexNode scopedObject, Scope parentScope)
        {
            var apexClassNode = scopedObject as ApexClassNode;
            if (apexClassNode != null)
            {
                apexClassNode.Scope = CreateClassScope(parentScope);
                return;
            }

            var apexMethod = scopedObject as ApexMethod;
            if (apexMethod != null)
            {
                apexMethod.Scope = CreateMethodScope(parentScope);
                return;
            }

            var statement = scopedObject as Statement;
            if (statement != null)
            {
                statement.Scope = CreateStatementScope(parentScope);
                return;
            }

            var apexProperty = scopedObject as ApexProperty;
            if (apexProperty != null)
            {
                apexProperty.Scope = CreatePropertyScope(parentScope);
                return;
            }

            var acessor = scopedObject as Acessor;
            if (acessor != null)
            {
                acessor.Scope = CreatePropertyScope(parentScope);
                return;
            }

            throw new NotImplementedException();
        }
    }

    public abstract class Scope
    {
        protected readonly Dictionary<string, ScopeMember> Members = new Dictionary<string, ScopeMember>();
        public Scope ParentScope { get; private set; }

        protected Scope(Scope paretnScope)
        {
            ParentScope = paretnScope;
        }

        protected void AddMemeber(string key, IApexNode node)
        {
            if (Members.ContainsKey(key))
            {
                Members[key].Nodes.Add(node);
                return;
            }
            Members.Add(key, new ScopeMember(node));
        }

        public virtual void AddMemeber(List<Modifier> modifiers, string ident, IApexNode node)
        {
            AddMemeber(ident, node);
        }

    }

    public class RootScope : Scope
    {
        public RootScope()
            : base(null)
        {
        }

        public void LoadFile(string path, IApexNode rootNode)
        {
            if (!Members.ContainsKey(path))
                Members.Add(path, new ScopeMember(rootNode));
            else
                Members[path] = new ScopeMember(rootNode);
        }
    }

    public class ApexFile : BaseApexNode, IIdent
    {
        public ApexFile(string ident, IApexNode item)
        {
            Ident = ident;
        }

        public string Ident { get; private set; }
    }

    public class ClassScope : Scope
    {
        public ClassScope(Scope paretnScope)
            : base(paretnScope)
        {
        }
    }

    public class ScopeMember
    {
        public ScopeMember(IApexNode node)
        {
            Nodes = new List<IApexNode> { node };
        }

        public List<IApexNode> Nodes { get; private set; }
    }

    public class InterfaceScope : Scope
    {
        public InterfaceScope(Scope paretnScope)
            : base(paretnScope)
        {
        }
    }
    public class EnumScope : Scope
    {
        public EnumScope(Scope paretnScope)
            : base(paretnScope)
        {
        }

        public void AddMembers(IEnumerable<string> membersIdents)
        {
            foreach (var membersIdent in membersIdents)
            {
                base.AddMemeber(membersIdent, new EnumValue(membersIdent));
            }
        }
    }

    public class EnumValue : BaseApexNode, IIdent
    {
        public EnumValue(string ident)
        {
            Ident = ident;
        }

        public string Ident { get; private set; }
    }

    public class BlockScope : Scope
    {
        public BlockScope(Scope paretnScope)
            : base(paretnScope)
        {
        }
    }
}
