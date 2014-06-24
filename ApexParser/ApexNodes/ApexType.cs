using System.Collections.Generic;

namespace ApexParser.ApexNodes
{
    public class ApexType : BaseApexNode, IIdent
    {
        private readonly List<ApexType> _genericTypes = new List<ApexType>();
        public ApexType(string ident)
        {
            Ident = ident;
        }
        public bool IsArray { get; set; }
        public void AddTypes(IEnumerable<ApexType> genericTypeArgumentList24)
        {
            _genericTypes.AddRange(genericTypeArgumentList24);
        }

        public string Ident { get; private set; }
    }
}