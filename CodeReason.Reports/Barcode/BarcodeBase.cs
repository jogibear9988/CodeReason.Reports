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
using System.Windows.Controls;
using System.Windows.Media;
using CodeReason.Reports.Interfaces;

namespace CodeReason.Reports.Barcode
{
    /// <summary>
    /// Base class for barcodes
    /// </summary>
    public class BarcodeBase : Canvas, IPropertyValue
    {
        /// <summary>
        /// Gets or sets the aggregate group
        /// </summary>
        public virtual string AggregateGroup
        {
            get { return (string)GetValue(AggregateGroupProperty); }
            set { SetValue(AggregateGroupProperty, value); }
        }

        // Using a DependencyProperty as the backing store for AggregateGroup.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty AggregateGroupProperty =
            DependencyProperty.Register("AggregateGroup", typeof(string), typeof(BarcodeBase), new UIPropertyMetadata(null));

        /// <summary>
        /// Gets or sets the brush which is to be uses to draw the bars
        /// </summary>
        public virtual Brush BrushBars
        {
            get { return (Brush)GetValue(BrushBarsProperty); }
            set { SetValue(BrushBarsProperty, value); RedrawAll(); }
        }

        // Using a DependencyProperty as the backing store for BrushBars.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty BrushBarsProperty =
            DependencyProperty.Register("BrushBars", typeof(Brush), typeof(BarcodeBase), new UIPropertyMetadata(Brushes.Black));

        /// <summary>
        /// Gets or sets the font family to be used to draw the barcode text
        /// </summary>
        public virtual FontFamily FontFamily
        {
            get { return (FontFamily)GetValue(FontFamilyProperty); }
            set { SetValue(FontFamilyProperty, value); RedrawAll(); }
        }

        // Using a DependencyProperty as the backing store for Font.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty FontFamilyProperty =
            DependencyProperty.Register("FontFamily", typeof(FontFamily), typeof(BarcodeBase), new UIPropertyMetadata(new FontFamily()));

        /// <summary>
        /// Gets or sets the font stretch property
        /// </summary>
        public virtual FontStretch FontStretch
        {
            get { return (FontStretch)GetValue(FontStretchProperty); }
            set { SetValue(FontStretchProperty, value); }
        }

        // Using a DependencyProperty as the backing store for FontStretch.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty FontStretchProperty =
            DependencyProperty.Register("FontStretch", typeof(FontStretch), typeof(BarcodeBase), new UIPropertyMetadata(new FontStretch()));

        /// <summary>
        /// Gets or sets the font style of the barcode text
        /// </summary>
        public virtual FontStyle FontStyle
        {
            get { return (FontStyle)GetValue(FontStyleProperty); }
            set { SetValue(FontStyleProperty, value); RedrawAll(); }
        }

        // Using a DependencyProperty as the backing store for FontStyle.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty FontStyleProperty =
            DependencyProperty.Register("FontStyle", typeof(FontStyle), typeof(BarcodeBase), new UIPropertyMetadata(new FontStyle()));

        /// <summary>
        /// Gets or sets the font weight of the barcode text
        /// </summary>
        public virtual FontWeight FontWeight
        {
            get { return (FontWeight)GetValue(FontWeightProperty); }
            set { SetValue(FontWeightProperty, value); RedrawAll(); }
        }

        // Using a DependencyProperty as the backing store for FontWeight.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty FontWeightProperty =
            DependencyProperty.Register("FontWeight", typeof(FontWeight), typeof(BarcodeBase), new UIPropertyMetadata(new FontWeight()));

        /// <summary>
        /// Gets or sets the value format
        /// </summary>
        public virtual string Format
        {
            get { return (string)GetValue(FormatProperty); }
            set { SetValue(FormatProperty, value); RedrawAll(); }
        }

        // Using a DependencyProperty as the backing store for Format.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty FormatProperty =
            DependencyProperty.Register("Format", typeof(string), typeof(BarcodeBase), new UIPropertyMetadata(null));

        /// <summary>
        /// Gets or sets the property name
        /// </summary>
        public virtual string PropertyName
        {
            get { return (string)GetValue(PropertyNameProperty); }
            set { SetValue(PropertyNameProperty, value); RedrawAll(); }
        }

        // Using a DependencyProperty as the backing store for PropertyName.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty PropertyNameProperty =
            DependencyProperty.Register("PropertyName", typeof(string), typeof(BarcodeBase), new UIPropertyMetadata(null));

        /// <summary>
        /// Enables or disables the option to show text below the barcode
        /// </summary>
        public virtual bool ShowText
        {
            get { return (bool)GetValue(ShowTextProperty); }
            set { SetValue(ShowTextProperty, value); RedrawAll(); }
        }

        // Using a DependencyProperty as the backing store for ShowText.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty ShowTextProperty =
            DependencyProperty.Register("ShowText", typeof(bool), typeof(BarcodeBase), new UIPropertyMetadata(true));

        /// <summary>
        /// Gets or sets the overridden text
        /// </summary>
        public virtual string Text
        {
            get { return (string)GetValue(TextProperty); }
            set { SetValue(TextProperty, value); RedrawAll(); }
        }

        // Using a DependencyProperty as the backing store for Text.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty TextProperty =
            DependencyProperty.Register("Text", typeof(string), typeof(BarcodeBase), new UIPropertyMetadata(null));

        /// <summary>
        /// Gets or sets the object value
        /// </summary>
        public virtual object Value
        {
            get { return GetValue(ValueProperty); }
            set { SetValue(ValueProperty, value); RedrawAll(); }
        }

        // Using a DependencyProperty as the backing store for Value.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty ValueProperty =
            DependencyProperty.Register("Value", typeof(object), typeof(BarcodeBase), new UIPropertyMetadata(null));

        /// <summary>
        /// Identifies the ValueChanged routed event.
        /// </summary>
        public static readonly RoutedEvent ValueChangedEvent = EventManager.RegisterRoutedEvent(
            "ValueChanged", RoutingStrategy.Bubble,
            typeof(RoutedPropertyChangedEventHandler<decimal>), typeof(BarcodeBase));

        /// <summary>
        /// Raises the ValueChanged event.
        /// </summary>
        /// <param name="args">Arguments associated with the ValueChanged event.</param>
        protected virtual void OnValueChanged(RoutedPropertyChangedEventArgs<decimal> args)
        {
            RaiseEvent(args);
        }

        /// <summary>
        /// Render size has changed
        /// </summary>
        /// <param name="sizeInfo">size info</param>
        protected override void OnRenderSizeChanged(SizeChangedInfo sizeInfo)
        {
            base.OnRenderSizeChanged(sizeInfo);
            RedrawAll();
        }

        /// <summary>
        /// Redraws the whole barcode
        /// </summary>
        public virtual void RedrawAll()
        {
            Children.Clear();
        }
    }
}
