using System.Collections.Generic;

namespace ApexParser.ApexNodes
{
    public class ApexFieldList : BaseApexNode,IModifier
    {
        private readonly ApexType _type9;
        private readonly List<ApexField> _variableDeclaratorList11;
        private List<ApexField> variableDeclaratorList36;

        public ApexFieldList(ApexType type9, List<Modifier> modifierList10, List<ApexField> variableDeclaratorList11)
        {
            _type9 = type9;
            _variableDeclaratorList11 = variableDeclaratorList11;
            Modifiers = modifierList10;
        }

        public ApexFieldList(List<Modifier> modifierList35, List<ApexField> variableDeclaratorList36)
        {
            this.Modifiers = modifierList35;
            this.variableDeclaratorList36 = variableDeclaratorList36;
        }

        public List<ApexField> ApexFields { get; set; }
        public List<Modifier> Modifiers { get; set; }
    }
}