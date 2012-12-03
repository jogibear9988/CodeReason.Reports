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
    /// Interface for values
    /// </summary>
    public interface IHasValue
    {
        /// <summary>
        /// Gets or sets the value format
        /// </summary>
        string Format { get; set; }

        /// <summary>
        /// Gets or sets the object value
        /// </summary>
        object Value { get; set; }
    }
}
