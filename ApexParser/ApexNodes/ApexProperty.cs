using System.Collections.Generic;
using ApexParser.Scopes;

namespace ApexParser.ApexNodes
{
    public class ApexProperty : BaseApexNode, IModifier,IIdent
    {
        private readonly ApexType _type13;
        private readonly List<IApexNode> _propertyDeclaration16;

        public ApexProperty(string text, ApexType type13, List<Modifier> modifierList14, List<IApexNode> propertyDeclaration16)
        {
            Ident = text;
            _type13 = type13;
            Modifiers = modifierList14;
            _propertyDeclaration16 = propertyDeclaration16;
        }

        public List<Modifier> Modifiers { get; set; }
        public string Ident { get; private set; }
    }
}