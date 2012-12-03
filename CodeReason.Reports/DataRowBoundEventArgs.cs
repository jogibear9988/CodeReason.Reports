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
using System.Windows.Documents;

namespace CodeReason.Reports
{
    /// <summary>
    /// Special event args for data row bound event
    /// </summary>
    public class DataRowBoundEventArgs : EventArgs
    {
        /// <summary>
        /// Gets the DataRow object being processed
        /// </summary>
        public DataRow DataRow { get; protected set; }

        /// <summary>
        /// Gets the associated ReportDocument
        /// </summary>
        public ReportDocument ReportDocument { get; protected set; }

        /// <summary>
        /// Gets or sets the table name
        /// </summary>
        public string TableName { get; set; }

        /// <summary>
        /// Gets or sets the newly created table row
        /// </summary>
        public TableRow TableRow { get; set; }

        /// <summary>
        /// Constructor
        /// </summary>
        public DataRowBoundEventArgs() : this(null, null)
        {
        }

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="report">associated report document</param>
        public DataRowBoundEventArgs(ReportDocument report) : this(report, null)
        {
        }

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="report">associated report document</param>
        /// <param name="row">DataRow object being processed</param>
        public DataRowBoundEventArgs(ReportDocument report, DataRow row)
        {
            ReportDocument = report;
            DataRow = row;
        }
    }
}
