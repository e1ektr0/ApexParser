using System.Collections.Generic;

namespace ApexParser.ApexNodes
{
    public class ApexProperty : BaseApexNode
    {
        private readonly string _text;
        private readonly ApexType _type13;
        private readonly List<Modifier> _modifierList14;
        private readonly List<IApexNode> _propertyDeclaration16;

        public ApexProperty(string text, ApexType type13, List<Modifier> modifierList14, List<IApexNode> propertyDeclaration16)
        {
            _text = text;
            _type13 = type13;
            _modifierList14 = modifierList14;
            _propertyDeclaration16 = propertyDeclaration16;
        }
    }
}