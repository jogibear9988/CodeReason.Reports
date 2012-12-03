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

namespace CodeReason.Reports.Charts.Visifire
{
    /// <summary>
    /// Represents a stacked bar chart
    /// </summary>
    public class StackedBarChart : ChartBase
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public StackedBarChart()
        {
            RenderAs = global::Visifire.Charts.RenderAs.StackedBar;
        }
    }
}
