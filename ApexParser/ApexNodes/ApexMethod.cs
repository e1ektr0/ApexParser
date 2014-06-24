using System.Collections.Generic;
using ApexParser.Scopes;

namespace ApexParser.ApexNodes
{
    public class ApexMethod : BaseScopedClass, IModifier,IIdent
    {
        private readonly ApexType _type6;
        private IApexNode block21;
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
            // TODO: Complete member initialization
            this.block21 = block21;
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
                ((Block)_block).Scope = Scope;
            }
        }

        public List<SignatureParam> parameters { get; set; }
        public Scope Scope { get; set; }
        public List<Modifier> Modifiers { get; set; }
    }
}