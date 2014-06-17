using System.Collections.Generic;

namespace ApexParser.ApexNodes
{
    public class ApexConstructor : BaseApexNode
    {
        private readonly List<Modifier> _modifierList12;

        public ApexConstructor(List<Modifier> modifierList12)
        {
            _modifierList12 = modifierList12;
        }
    }
}