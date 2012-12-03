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

namespace CodeReason.Reports.Interfaces
{
    /// <summary>
    /// Interface for values to be used as aggregate values
    /// </summary>
    public interface IAggregateValue
    {
        /// <summary>
        /// Gets or sets the aggregate group
        /// </summary>
        string AggregateGroup { get; set; }
    }
}
