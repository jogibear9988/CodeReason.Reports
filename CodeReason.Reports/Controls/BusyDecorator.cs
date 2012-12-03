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
using System.Threading;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Threading;

namespace CodeReason.Reports.Controls
{
    [StyleTypedProperty(Property = "BusyStyle", StyleTargetType = typeof(Control))]
    public class BusyDecorator : Decorator
    {
        private ThreadedVisualHost _busyHost = new ThreadedVisualHost();

        ///// <summary>
        ///// Gets or sets the indicator size
        ///// </summary>
        //public double IndicatorSize
        //{
        //    get { return (double)GetValue(IndicatorSizeProperty); }
        //    set { SetValue(IndicatorSizeProperty, value); }
        //}

        //// Using a DependencyProperty as the backing store for IndicatorSize.  This enables animation, styling, binding, etc...
        //public static readonly DependencyProperty IndicatorSizeProperty =
        //    DependencyProperty.Register("IndicatorSize", typeof(double), typeof(BusyDecorator),
        //    new FrameworkPropertyMetadata(64d, OnIndicatorSizeChanged));

        //static void OnIndicatorSizeChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
        //{
        //}

        /// <summary>
        /// Identifies the IsBusyIndicatorShowing dependency property.
        /// </summary>
        public static readonly DependencyProperty IsBusyIndicatorHiddenProperty =
            DependencyProperty.Register("IsBusyIndicatorHidden", typeof(bool), typeof(BusyDecorator),
            new FrameworkPropertyMetadata(true, FrameworkPropertyMetadataOptions.AffectsMeasure));

        /// <summary>
        /// Gets or sets if the BusyIndicator is being shown.
        /// </summary>
        public bool IsBusyIndicatorHidden
        {
            get { return (bool)GetValue(IsBusyIndicatorHiddenProperty); }
            set { SetValue(IsBusyIndicatorHiddenProperty, value); }
        }

        /// <summary>
        /// Identifies the <see cref="BusyStyle" /> property.
        /// </summary>
        public static readonly DependencyProperty BusyStyleProperty =
            DependencyProperty.Register(
            "BusyStyle",
            typeof(Style),
            typeof(BusyDecorator),
            new FrameworkPropertyMetadata(OnBusyStyleChanged));

        /// <summary>
        /// Gets or sets the Style to apply to the Control that is displayed as the busy indication.
        /// </summary>
        public Style BusyStyle
        {
            get { return (Style)GetValue(BusyStyleProperty); }
            set { SetValue(BusyStyleProperty, value); }
        }

        static void OnBusyStyleChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
        {
            BusyDecorator bd = (BusyDecorator)d;
            Style nVal = (Style)e.NewValue;
            bd._busyHost.CreateContent = () => new Control { Style = nVal };
        }

        /// <summary>
        /// Identifies the <see cref="BusyHorizontalAlignment" /> property.
        /// </summary>
        public static readonly DependencyProperty BusyHorizontalAlignmentProperty = DependencyProperty.Register(
          "BusyHorizontalAlignment",
          typeof(HorizontalAlignment),
          typeof(BusyDecorator),
          new FrameworkPropertyMetadata(HorizontalAlignment.Center));

        /// <summary>
        /// Gets or sets the HorizontalAlignment to use to layout the control that contains the busy indicator control.
        /// </summary>
        public HorizontalAlignment BusyHorizontalAlignment
        {
            get { return (HorizontalAlignment)GetValue(BusyHorizontalAlignmentProperty); }
            set { SetValue(BusyHorizontalAlignmentProperty, value); }
        }

        /// <summary>
        /// Identifies the <see cref="BusyVerticalAlignment" /> property.
        /// </summary>
        public static readonly DependencyProperty BusyVerticalAlignmentProperty = DependencyProperty.Register(
          "BusyVerticalAlignment",
          typeof(VerticalAlignment),
          typeof(BusyDecorator),
          new FrameworkPropertyMetadata(VerticalAlignment.Center));

        /// <summary>
        /// Gets or sets the the VerticalAlignment to use to layout the control that contains the busy indicator.
        /// </summary>
        public VerticalAlignment BusyVerticalAlignment
        {
            get { return (VerticalAlignment)GetValue(BusyVerticalAlignmentProperty); }
            set { SetValue(BusyVerticalAlignmentProperty, value); }
        }

        /// <summary>
        /// Gets the visual children count
        /// </summary>
        protected override int VisualChildrenCount
        {
            get { return Child == null ? 1 : 2; }
        }

        /// <summary>
        /// Gets the enumerator for all logical children
        /// </summary>
        protected override System.Collections.IEnumerator LogicalChildren
        {
            get
            {
                if (Child != null) yield return Child;
                yield return _busyHost;
            }
        }

        /// <summary>
        /// Gets the visual child by index
        /// </summary>
        /// <param name="index">index</param>
        /// <returns>visual child</returns>
        /// <exception cref="IndexOutOfRangeException">index</exception>
        protected override System.Windows.Media.Visual GetVisualChild(int index)
        {
            if (Child != null)
            {
                switch (index)
                {
                    case 0:
                        return Child;

                    case 1:
                        return _busyHost;
                }
            }
            else if (index == 0) return _busyHost;

            throw new IndexOutOfRangeException("index");
        }

        /// <summary>
        /// Static constructor
        /// </summary>
        static BusyDecorator()
        {
            DefaultStyleKeyProperty.OverrideMetadata(
                typeof(BusyDecorator),
                new FrameworkPropertyMetadata(typeof(BusyDecorator)));
        }

        /// <summary>
        /// Constructor
        /// </summary>
        public BusyDecorator()
        {
            AddLogicalChild(_busyHost);
            AddVisualChild(_busyHost);

            SetBinding(_busyHost, IsBusyIndicatorHiddenProperty, ThreadedVisualHost.IsContentHiddenProperty);
            SetBinding(_busyHost, BusyHorizontalAlignmentProperty, HorizontalAlignmentProperty);
            SetBinding(_busyHost, BusyVerticalAlignmentProperty, VerticalAlignmentProperty);
        }

        private void SetBinding(DependencyObject obj, DependencyProperty source, DependencyProperty target)
        {
            Binding b = new Binding();
            b.Source = this;
            b.Path = new PropertyPath(source);
            BindingOperations.SetBinding(obj, target, b);
        }

        /// <summary>
        /// Overwritten measure method
        /// </summary>
        /// <param name="availableSize">available size</param>
        /// <returns>measured size</returns>
        protected override Size MeasureOverride(Size availableSize)
        {
            Size ret = new Size(0, 0);
            if (Child != null)
            {
                Child.Measure(availableSize);
                ret = Child.DesiredSize;
            }

            _busyHost.Measure(availableSize);

            return new Size(Math.Max(ret.Width, _busyHost.DesiredSize.Width), Math.Max(ret.Height, _busyHost.DesiredSize.Height));
        }

        /// <summary>
        /// Overwritten arrange method
        /// </summary>
        /// <param name="arrangeSize">arrange size</param>
        /// <returns>arranged size</returns>
        protected override Size ArrangeOverride(Size arrangeSize)
        {
            Size ret = new Size(0, 0);
            if (Child != null)
            {
                Child.Arrange(new Rect(arrangeSize));
                ret = Child.RenderSize;
            }

            _busyHost.Arrange(new Rect(arrangeSize));

            return new Size(Math.Max(ret.Width, _busyHost.RenderSize.Width), Math.Max(ret.Height, _busyHost.RenderSize.Height));
        }
    }
}
