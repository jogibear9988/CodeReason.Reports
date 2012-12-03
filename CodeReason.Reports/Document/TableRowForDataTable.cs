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

using System.Windows.Documents;
using CodeReason.Reports.Interfaces;

namespace CodeReason.Reports.Document
{
    /// <summary>
    /// Class for fillable table row values
    /// </summary>
    public class TableRowForDataTable : TableRow, ITableRowForDataTable
    {
        private string _tableName;
        /// <summary>
        /// Gets or sets the table name
        /// </summary>
        public string TableName
        {
            get { return _tableName; }
            set { _tableName = value; }
        }
    }
}
