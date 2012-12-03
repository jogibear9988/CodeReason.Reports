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
using System.Windows.Threading;
using System.Windows.Media;
using System.Threading;
using System.Windows;

namespace CodeReason.Reports.Controls
{
    /// <summary>
    /// Delegate for create content
    /// </summary>
    /// <returns></returns>
    public delegate Visual CreateContentDelegate();

    /// <summary>
    /// Threaded visual host
    /// </summary>
    internal class ThreadedVisualHost : FrameworkElement
    {
        /// <summary>
        /// Threaded visual helper class
        /// </summary>
        private class ThreadedVisualHelper
        {
            private AutoResetEvent _resetEvent = new AutoResetEvent(false);
            private CreateContentDelegate _createContent;
            private Action _invalidateMeasure;

            private HostVisual _hostVisual;
            public HostVisual HostVisual { get { return _hostVisual; } }

            public Size DesiredSize { get; private set; }
            private Dispatcher Dispatcher { get; set; }

            /// <summary>
            /// Constructor
            /// </summary>
            /// <param name="createContent">create content delegate</param>
            /// <param name="invalidateMeasure">action to invalidate the measure</param>
            public ThreadedVisualHelper(CreateContentDelegate createContent, Action invalidateMeasure)
            {
                _hostVisual = new HostVisual();
                _createContent = createContent;
                _invalidateMeasure = invalidateMeasure;

                Thread backgroundUi = new Thread(CreateAndShowContent);
                backgroundUi.SetApartmentState(ApartmentState.STA);
                backgroundUi.IsBackground = true;
                backgroundUi.Start();

                _resetEvent.WaitOne();
            }

            /// <summary>
            /// Stops the thread
            /// </summary>
            public void Stop()
            {
                Dispatcher.BeginInvokeShutdown(DispatcherPriority.Send);
            }

            private void CreateAndShowContent()
            {
                Dispatcher = Dispatcher.CurrentDispatcher;
                VisualTargetPresentationSource source = new VisualTargetPresentationSource(_hostVisual);
                _resetEvent.Set();
                source.RootVisual = _createContent();
                DesiredSize = source.DesiredSize;
                _invalidateMeasure();

                Dispatcher.Run();
                source.Dispose();
            }
        }

        private ThreadedVisualHelper _threadedHelper;
        private HostVisual _hostVisual;

        /// <summary>
        /// Identifies the IsContentHidden dependency property.
        /// </summary>
        public static readonly DependencyProperty IsContentHiddenProperty = DependencyProperty.Register(
            "IsContentHidden",
            typeof(bool),
            typeof(ThreadedVisualHost),
            new FrameworkPropertyMetadata(false, OnIsContentHiddenChanged));

        /// <summary>
        /// Gets or sets if the content is being displayed.
        /// </summary>
        public bool IsContentHidden
        {
            get { return (bool)GetValue(IsContentHiddenProperty); }
            set { SetValue(IsContentHiddenProperty, value); }
        }

        private static void OnIsContentHiddenChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
        {
            ThreadedVisualHost bvh = (ThreadedVisualHost)d;

            if (bvh.CreateContent != null)
            {
                if (!(bool)e.NewValue) bvh.CreateContentHelper(); else bvh.HideContentHelper();
            }
        }

        /// <summary>
        /// Identifies the CreateContent dependency property.
        /// </summary>
        public static readonly DependencyProperty CreateContentProperty = DependencyProperty.Register(
            "CreateContent",
            typeof(CreateContentDelegate),
            typeof(ThreadedVisualHost),
            new FrameworkPropertyMetadata(OnCreateContentChanged));

        /// <summary>
        /// Gets or sets the function used to create the visual to display in a background thread.
        /// </summary>
        public CreateContentDelegate CreateContent
        {
            get { return (CreateContentDelegate)GetValue(CreateContentProperty); }
            set { SetValue(CreateContentProperty, value); }
        }

        private static void OnCreateContentChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
        {
            ThreadedVisualHost bvh = (ThreadedVisualHost)d;

            if (bvh.IsContentHidden)
            {
                bvh.HideContentHelper();
                if (e.NewValue != null) bvh.CreateContentHelper();
            }
        }

        /// <summary>
        /// Gets the visual childen count
        /// </summary>
        protected override int VisualChildrenCount
        {
            get { return _hostVisual != null ? 1 : 0; }
        }

        /// <summary>
        /// Gets a visual child by index
        /// </summary>
        /// <param name="index">index</param>
        /// <returns></returns>
        /// <exception cref="IndexOutOfRangeException">index</exception>
        protected override Visual GetVisualChild(int index)
        {
            if ((_hostVisual != null) && (index == 0)) return _hostVisual;

            throw new IndexOutOfRangeException("index");
        }

        /// <summary>
        /// Gets the enumerator for all logical children
        /// </summary>
        protected override System.Collections.IEnumerator LogicalChildren
        {
            get { if (_hostVisual != null) yield return _hostVisual; }
        }

        private void CreateContentHelper()
        {
            _threadedHelper = new ThreadedVisualHelper(CreateContent, SafeInvalidateMeasure);
            _hostVisual = _threadedHelper.HostVisual;
        }

        private void SafeInvalidateMeasure()
        {
            Dispatcher.BeginInvoke(new Action(InvalidateMeasure), DispatcherPriority.Loaded);
        }

        private void HideContentHelper()
        {
            if (_threadedHelper != null)
            {
                _threadedHelper.Stop();
                _threadedHelper = null;
                InvalidateMeasure();
            }
        }

        /// <summary>
        /// Overwritten measure method
        /// </summary>
        /// <param name="availableSize">available size</param>
        /// <returns></returns>
        protected override Size MeasureOverride(Size availableSize)
        {
            if (_threadedHelper != null) return _threadedHelper.DesiredSize;

            return base.MeasureOverride(availableSize);
        }
    }
}
