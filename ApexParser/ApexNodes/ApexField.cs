namespace ApexParser.ApexNodes
{
    public class ApexField
    {
        public ApexField(string text)
        {
            
        }

        public bool IsArray { get; set; }

        public IApexNode Initializer { get; set; }
    }
}