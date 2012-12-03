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
    /// Represents a stacked column 100 chart
    /// </summary>
    public class StackedColumn100Chart : ChartBase
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public StackedColumn100Chart()
        {
            RenderAs = global::Visifire.Charts.RenderAs.StackedColumn100;
        }
    }
}
