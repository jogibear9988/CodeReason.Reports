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
using System.Windows.Media;
using System.Windows;

namespace CodeReason.Reports.Controls
{
    /// <summary>
    /// Visual target presentation source
    /// </summary>
    public class VisualTargetPresentationSource : PresentationSource
    {
        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="hostVisual">host visual</param>
        public VisualTargetPresentationSource(HostVisual hostVisual)
        {
            _visualTarget = new VisualTarget(hostVisual);
            AddSource();
        }

        private bool _isDisposed;
        /// <summary>
        /// Object is disposed
        /// </summary>
        public override bool IsDisposed
        {
            get { return _isDisposed; }
        }

        public Size DesiredSize { get; protected set; }

        private VisualTarget _visualTarget;
        /// <summary>
        /// Root visual
        /// </summary>
        public override Visual RootVisual
        {
            get { return _visualTarget.RootVisual; }
            set
            {
                Visual oldRoot = _visualTarget.RootVisual;
                _visualTarget.RootVisual = value;

                RootChanged(oldRoot, value);

                UIElement rootElement = value as UIElement;
                if (rootElement != null)
                {
                    rootElement.Measure(new Size(Double.PositiveInfinity, Double.PositiveInfinity));
                    rootElement.Arrange(new Rect(rootElement.DesiredSize));

                    DesiredSize = rootElement.DesiredSize;
                    return;
                }

                DesiredSize = new Size(0, 0);
            }
        }

        /// <summary>
        /// Gets the composition target core
        /// </summary>
        /// <returns></returns>
        protected override CompositionTarget GetCompositionTargetCore()
        {
            return _visualTarget;
        }

        /// <summary>
        /// Internal dispose method
        /// </summary>
        internal void Dispose()
        {
            if (_isDisposed) return;

            RemoveSource();
            _isDisposed = true;
        }
    }
}
