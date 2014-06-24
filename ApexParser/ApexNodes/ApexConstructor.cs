using System.Collections.Generic;

namespace ApexParser.ApexNodes
{
    public class ApexConstructor : BaseApexNode,IModifier
    {

        public ApexConstructor(List<Modifier> modifierList12)
        {
            Modifiers = modifierList12;
        }

        public List<Modifier> Modifiers { get; set; }
    }
}