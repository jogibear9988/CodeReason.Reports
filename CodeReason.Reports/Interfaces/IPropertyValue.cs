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
    /// Interface for property values
    /// </summary>
    public interface IPropertyValue : IHasValue
    {
        /// <summary>
        /// Gets or sets the property name
        /// </summary>
        string PropertyName { get; set; }
    }
}
