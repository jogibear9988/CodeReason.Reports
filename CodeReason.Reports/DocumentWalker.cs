/************************************************************************
 * Copyright: Hans Wolff
 *
 * License:  This software abides by the LGPL license terms. For further
 *           licensing information please see the top level LICENSE.txt 
 *           file found in the root directory of CodeReason Reports.
 *
 * Author:   Hans Wolff
 *
 ************************************************************************/

using System.Collections.Generic;
using System.Windows.Documents;
using System.Windows.Controls;

namespace CodeReason.Reports
{
    /// <summary>
    /// THe delegate type of the event that will be raised
    /// </summary>
    public delegate void DocumentVisitedEventHandler(object sender, object visitedObject, bool start);

    /// <summary>
    /// The Document walker class enables a traversal of the flow document tree and raises an event for each node 
    /// in the document tree. I used it to find all instances of a FormattedRun control in the flowdocument defintion. 
    /// It is pretty straightforward, so I will just show the code itself. 
    /// </summary>
    public class DocumentWalker
    {
        private object _tag;
        /// <summary>
        /// Gets or sets the tag associated to this walker
        /// </summary>
        public object Tag
        {
            get { return _tag; }
            set { _tag = value; }
        }

        /// <summary>
        /// This is the event to hook on.
        /// </summary>
        public event DocumentVisitedEventHandler VisualVisited;

        /// <summary>
        /// Traverses whole document
        /// </summary>
        /// <param name="fd">FlowDocument</param>
        /// <returns>list of inlines</returns>
        public List<Inline> Walk(FlowDocument fd)
        {
            return TraverseBlockCollection<Inline>(fd.Blocks);
        }

        /// <summary>
        /// Traverses whole document
        /// </summary>
        /// <param name="fd">FlowDocument</param>
        /// <returns>list of inlines</returns>
        public List<T> Walk<T>(FlowDocument fd) where T : class
        {
            return TraverseBlockCollection<T>(fd.Blocks);
        }

        /// <summary>
        /// Traverses an InlineCollection
        /// </summary>
        /// <param name="inlines">InlineCollection to be traversed</param>
        /// <returns>list of inlines</returns>
        public List<T> TraverseInlines<T>(InlineCollection inlines) where T : class
        {
            List<T> res = new List<T>();
            if (inlines != null && inlines.Count > 0)
            {
                Inline il = inlines.FirstInline;
                while (il != null)
                {
                    if (il is T) res.Add(il as T);

                    Run r = il as Run;
                    if (r != null)
                    {
                        if (VisualVisited != null) VisualVisited(this, r, true);
                        il = il.NextInline;
                        continue;
                    }

                    
                    Span sp = il as Span;
                    if (sp != null)
                    {
                        if (VisualVisited != null) 
                            VisualVisited(this, sp, true);

                        res.AddRange(TraverseInlines<T>(sp.Inlines));
                        il = il.NextInline;
                        continue;
                    }
                                                            
                    InlineUIContainer uc = il as InlineUIContainer;                  
                    if (uc != null && uc.Child != null)
                    {
                        if (VisualVisited != null) VisualVisited(this, uc.Child, true);
                        if (uc.Child is T) res.Add(uc.Child as T);
                        TextBlock tb = uc.Child as TextBlock;
                        if (tb != null) 
                            res.AddRange(TraverseInlines<T>(tb.Inlines));                        

                        il = il.NextInline;
                        continue;
                    }
                    Figure fg = il as Figure;                    
                    if (fg != null)
                    {
                        if (VisualVisited != null) VisualVisited(this, fg, true);
                        res.AddRange(TraverseBlockCollection<T>(fg.Blocks));
                    }
                    il = il.NextInline;
                }
            }
            return res;
        }

     
        /// <summary>
        /// Traverses only passed paragraph
        /// </summary>
        /// <param name="p">paragraph</param>
        /// <returns>list of inlines</returns>
        public List<T> TraverseParagraph<T>(Paragraph p) where T : class
        {
            return TraverseInlines<T>(p.Inlines);
        }

        /// <summary>
        /// Traverses passed block collection
        /// </summary>
        /// <param name="blocks">blocks to be traversed</param>
        /// <returns>list of inlines</returns>
        ///    
        public List<T> TraverseBlockCollection<T>(IEnumerable<Block> blocks) where T : class
        {
            List<T> res = new List<T>();
            foreach (Block b in blocks)
            {
                if (b is T)
                {
                    if (VisualVisited != null) VisualVisited(this, b, true);
                    res.Add(b as T);
                }

                Paragraph p = b as Paragraph;
                if (p != null)
                {
                    if (VisualVisited != null) VisualVisited(this, p, true);
                    res.AddRange(TraverseParagraph<T>(p));
                    continue;
                }

                BlockUIContainer bui = b as BlockUIContainer;
                if (bui != null)
                {
                    if (VisualVisited != null) VisualVisited(this, bui.Child, true);
                    continue;
                }

                Section s = b as Section;
                if (s != null)
                {
                    if (VisualVisited != null) VisualVisited(this, s, true);
                    res.AddRange(TraverseBlockCollection<T>(s.Blocks));
                    continue;
                }
         
                Table t = b as Table;
                if (t != null)
                {
                    if (VisualVisited != null) VisualVisited(this, t, true);
                    foreach (TableRowGroup trg in t.RowGroups)
                    {
                        if (VisualVisited != null) VisualVisited(this, trg, true);
                        foreach (TableRow tr in trg.Rows)
                        {
                            if (VisualVisited != null) VisualVisited(this, tr, true);
                            if (tr is T) res.Add(tr as T);

                            foreach (TableCell tc in tr.Cells)
                            {
                                if (VisualVisited != null) VisualVisited(this, tc, true);
                                res.AddRange(TraverseBlockCollection<T>(tc.Blocks));
                            }
                        }
                    }
                    continue;
                }
            }
            return res;
        }
    }
}
