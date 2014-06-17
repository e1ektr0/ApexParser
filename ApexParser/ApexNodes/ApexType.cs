using System.Collections.Generic;

namespace ApexParser.ApexNodes
{
    public class ApexType : BaseApexNode
    {
        private readonly string _ident;
        private readonly List<ApexType> _genericTypes = new List<ApexType>();
        public ApexType(string ident)
        {
            _ident = ident;
        }
        public bool IsArray { get; set; }
        public void AddTypes(IEnumerable<ApexType> genericTypeArgumentList24)
        {
            _genericTypes.AddRange(genericTypeArgumentList24);
        }
    }
}