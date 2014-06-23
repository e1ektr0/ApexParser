using System.Collections.Generic;

namespace ApexParser.ApexNodes
{
    public class ApexFieldList : BaseApexNode
    {
        private List<Modifier> modifierList35;
        private List<ApexField> variableDeclaratorList36;

        public ApexFieldList(ApexType type9, List<Modifier> modifierList10, List<ApexField> variableDeclaratorList11)
        {
                
        }

        public ApexFieldList(List<Modifier> modifierList35, List<ApexField> variableDeclaratorList36)
        {
            // TODO: Complete member initialization
            this.modifierList35 = modifierList35;
            this.variableDeclaratorList36 = variableDeclaratorList36;
        }

        public List<ApexField> ApexFields { get; set; }
    }
}