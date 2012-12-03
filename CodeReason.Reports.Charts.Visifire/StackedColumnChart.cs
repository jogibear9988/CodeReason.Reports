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
    /// Represents a stacked column chart
    /// </summary>
    public class StackedColumnChart : ChartBase
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public StackedColumnChart()
        {
            RenderAs = global::Visifire.Charts.RenderAs.StackedColumn;
        }
    }
}
