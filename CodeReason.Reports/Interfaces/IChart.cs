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

using System;
using System.Data;

namespace CodeReason.Reports.Interfaces
{
    /// <summary>
    /// Interface for a chart object
    /// </summary>
    public interface IChart : ICloneable
    {
        /// <summary>
        /// Gets or sets the table columns which are used to draw the chart
        /// </summary>
        string TableColumns { get; set; }

        /// <summary>
        /// Gets or sets the table name containing the data to be drawn
        /// </summary>
        string TableName { get; set; }

        /// <summary>
        /// Gets or sets the data columns which are used to draw the chart
        /// </summary>
        string[] DataColumns { get; set; }

        /// <summary>
        /// Data view to be used to draw the data
        /// </summary>
        DataView DataView { get; set; }

        /// <summary>
        /// Updates the chart to use the chart data
        /// </summary>
        void UpdateChart();
    }
}
