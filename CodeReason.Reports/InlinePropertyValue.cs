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

using System.Windows;
using CodeReason.Reports.Interfaces;

namespace CodeReason.Reports
{
    /// <summary>
    /// Abstract class for fillable run values
    /// </summary>
    public abstract class InlinePropertyValue : InlineHasValue, IPropertyValue
    {
        /// <summary>
        /// Gets or sets the property name
        /// </summary>
        public virtual string PropertyName
        {
            get { return (string)GetValue(PropertyNameProperty); }
            set { SetValue(PropertyNameProperty, value); }
        }

        // Using a DependencyProperty as the backing store for PropertyName.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty PropertyNameProperty =
            DependencyProperty.Register("PropertyName", typeof(string), typeof(InlinePropertyValue), new UIPropertyMetadata(null));
    }
}
