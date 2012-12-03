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
    /// Represents a column chart
    /// </summary>
    public class ColumnChart : ChartBase
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public ColumnChart()
        {
            RenderAs = global::Visifire.Charts.RenderAs.Column;
        }
    }
}
