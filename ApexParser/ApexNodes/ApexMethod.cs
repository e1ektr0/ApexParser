using System.Collections.Generic;

namespace ApexParser.ApexNodes
{
    public class ApexMethod : BaseApexNode
    {
        private readonly List<Modifier> _modifierList8;
        private readonly string _text;
        private readonly List<Modifier> _modifierList5;
        private readonly ApexType _type6;

        public ApexMethod(string text, List<Modifier> modifierList5, ApexType type6)
        {
            _text = text;
            _modifierList5 = modifierList5;
            _type6 = type6;
        }

        public ApexMethod(string text, List<Modifier> modifierList8)
        {
            _text = text;
            _modifierList8 = modifierList8;
        }
        public ApexMethod()
        {
        }

        public string Ident { get; set; }
        public List<Modifier> ModifierList { get; set; }
        public ApexType Type { get; set; }
        public IApexNode Block { get; set; }

        public List<SignatureParam> parameters { get; set; }
    }
}