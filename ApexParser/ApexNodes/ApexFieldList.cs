using System.Collections.Generic;

namespace ApexParser.ApexNodes
{
    public class ApexFieldList : BaseApexNode
    {
        public ApexFieldList(ApexType type9, List<Modifier> modifierList10, List<ApexField> variableDeclaratorList11)
        {
                
        }

        public List<ApexField> ApexFields { get; set; }
    }
}