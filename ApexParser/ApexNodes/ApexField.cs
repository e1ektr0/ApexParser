namespace ApexParser.ApexNodes
{
    public class ApexField : IIdent
    {
        public ApexField(string ident)
        {
            Ident = ident;
        }

        public bool IsArray { get; set; }
        
        public IApexNode Initializer { get; set; }
        
        public string Ident { get; private set; }
    }
}