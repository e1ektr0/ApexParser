using System.Collections.Generic;
using System.Linq;

namespace ApexParser.ApexNodes
{
    public abstract class BaseApexNode : IApexNode
    {
        public readonly List<IApexNode> Nodes = new List<IApexNode>();

        public virtual void Add(IApexNode node)
        {
            Nodes.Add(node);
        }

        public virtual void AddRage<T>(IList<T> nodes) where T : IApexNode
        {
            Nodes.AddRange(nodes.Cast<IApexNode>());
        }
    }
}