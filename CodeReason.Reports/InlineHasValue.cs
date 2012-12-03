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
using System.Windows;
using System.Windows.Documents;
using CodeReason.Reports.Interfaces;

namespace CodeReason.Reports
{
    /// <summary>
    /// Abstract class for fillable run values
    /// </summary>
    public abstract class InlineHasValue : Run, IHasValue
    {
        /// <summary>
        /// Gets or sets the value format
        /// </summary>
        public virtual string Format
        {
            get { return (string)GetValue(FormatProperty); }
            set { SetValue(FormatProperty, value); }
        }

        // Using a DependencyProperty as the backing store for Format.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty FormatProperty =
            DependencyProperty.Register("Format", typeof(string), typeof(InlineHasValue), new UIPropertyMetadata(null));

        /// <summary>
        /// Gets or sets the object value
        /// </summary>
        public virtual object Value
        {
            get { return GetValue(ValueProperty); }
            set { SetValue(ValueProperty, value); Text = FormatValue(value, Format); }
        }

        // Using a DependencyProperty as the backing store for Value.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty ValueProperty =
            DependencyProperty.Register("Value", typeof(object), typeof(InlineHasValue), new UIPropertyMetadata(null));

        /// <summary>
        /// Identifies the ValueChanged routed event.
        /// </summary>
        public static readonly RoutedEvent ValueChangedEvent = EventManager.RegisterRoutedEvent(
            "ValueChanged", RoutingStrategy.Bubble,
            typeof(RoutedPropertyChangedEventHandler<decimal>), typeof(InlineHasValue));

        /// <summary>
        /// Raises the ValueChanged event.
        /// </summary>
        /// <param name="args">Arguments associated with the ValueChanged event.</param>
        protected virtual void OnValueChanged(RoutedPropertyChangedEventArgs<decimal> args)
        {
            RaiseEvent(args);
        }

        /// <summary>
        /// Formats a value for output
        /// </summary>
        /// <param name="value">value</param>
        /// <param name="format">format</param>
        /// <returns></returns>
        public static string FormatValue(object value, string format)
        {
            if (value == null) return "";
            if (String.IsNullOrEmpty(format)) return value.ToString();

            Type type = value.GetType();
            if (type == typeof(DateTime)) return ((DateTime)value).ToString(format);
            if (type == typeof(decimal)) return ((decimal)value).ToString(format);
            if (type == typeof(double)) return ((double)value).ToString(format);
            if (type == typeof(float)) return ((float)value).ToString(format);
            if (type == typeof(int)) return ((int)value).ToString(format);
            if (type == typeof(long)) return ((long)value).ToString(format);
            if (type == typeof(short)) return ((short)value).ToString(format);
            if (type == typeof(uint)) return ((uint)value).ToString(format);
            if (type == typeof(ulong)) return ((ulong)value).ToString(format);
            if (type == typeof(ushort)) return ((ushort)value).ToString(format);

            return value.ToString();
        }
    }
}
