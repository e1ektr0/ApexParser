using System.Collections.Generic;

namespace ApexParser.ApexNodes
{
    public class ApexMethod : BaseScopedClass, IModifier,IIdent
    {
        private readonly ApexType _type6;
        private IApexNode _block;

        public ApexMethod()
        {
            Modifiers = new List<Modifier>();
        }
        /// <summary>
        /// Инициалайзеры
        /// </summary>
        public ApexMethod(IApexNode block21)
        {
            this._block = block21;
        }

        public string Ident { get; set; }
        public List<Modifier> ModifierList { get; set; }
        public ApexType Type { get; set; }

        public IApexNode Block  
        {
            get { return _block; }
            set
            {
                _block = value;
                Nodes.Add(_block);
            }
        }

        public List<SignatureParam> parameters { get; set; }
        public List<Modifier> Modifiers { get; set; }
    }
}