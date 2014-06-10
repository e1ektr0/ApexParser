using System.Collections.Generic;

namespace ApexParser.ApexNodes
{
    public interface IApexNode
    {
       // ApexType Evaluate();
    }

    public class ApexType
    {
        public ApexType(string ident)
        {
        }

        public void AddTypes(List<ApexType> genericTypeArgumentList17)
        {
                
        }

        public void AddType(ApexType typeIdent15)
        {
            
        }
    }

    public class ApexFieldList:IApexNode
    {
        public ApexFieldList(ApexType type9, List<Modifier> modifierList10, List<ApexField> variableDeclaratorList11)
        {
                
        }

        public List<ApexField> ApexFields { get; set; }
     
    }

    public class ApexProperty:IApexNode
    {
        public ApexProperty(ApexType type13, List<Modifier> modifierList14)
        {
            
        }

    }

    public class ApexConstructor:IApexNode
    {
        public ApexConstructor(List<Modifier> modifierList12)
        {
            
        }

    }

    public class ApexField
    {
        public ApexField(string text)
        {
            
        }

        public bool IsArray { get; set; }
    }

    public class ApexMethod:IApexNode
    {
        public ApexMethod(string text, List<Modifier> modifierList5, ApexType type6)
        {
                
        }

        public ApexMethod(string text, List<Modifier> modifierList8)
        {
            
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

    public class ApexClassNode : IApexNode
    {
        public void Add(IApexNode classScopeDeclarations3)
        {
                
        }
    }
}
