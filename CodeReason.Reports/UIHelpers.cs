using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Security;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Markup;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Xps.Serialization;

using Microsoft.Win32.SafeHandles;

namespace CodeReason.Reports
{
    public static class UIHelpers
    {
        internal class DeviceHelper
        {
            public static Int32 PixelsPerInch(Orientation orientation)
            {
                Int32 capIndex = (orientation == Orientation.Horizontal) ? 0x58 : 90;
                using (DCSafeHandle handle = UnsafeNativeMethods.CreateDC("DISPLAY"))
                {
                    return (handle.IsInvalid ? 0x60 : UnsafeNativeMethods.GetDeviceCaps(handle, capIndex));
                }
            }
        }

        internal sealed class DCSafeHandle : SafeHandleZeroOrMinusOneIsInvalid
        {
            private DCSafeHandle()
                : base(true)
            {
            }

            protected override Boolean ReleaseHandle()
            {
                return UnsafeNativeMethods.DeleteDC(base.handle);
            }
        }

        [SuppressUnmanagedCodeSecurity]
        internal static class UnsafeNativeMethods
        {
            [DllImport("gdi32.dll", CharSet = CharSet.Auto, ExactSpelling = true)]
            public static extern Boolean DeleteDC(IntPtr hDC);

            [DllImport("gdi32.dll", CharSet = CharSet.Auto, ExactSpelling = true)]
            public static extern Int32 GetDeviceCaps(DCSafeHandle hDC, Int32 nIndex);

            [DllImport("gdi32.dll", EntryPoint = "CreateDC", CharSet = CharSet.Auto)]
            public static extern DCSafeHandle IntCreateDC(String lpszDriver, String lpszDeviceName, String lpszOutput, IntPtr devMode);

            public static DCSafeHandle CreateDC(String lpszDriver)
            {
                return UnsafeNativeMethods.IntCreateDC(lpszDriver, null, null, IntPtr.Zero);
            }
        }

        public static BitmapSource CreateBitmapFromVisual(Double width, Double height, Visual visualToRender, Boolean undoTransformation)
        {
            if (visualToRender == null)
            {
                return null;
            }

            // The PixelsPerInch() helper method is used to read the screen DPI setting.
            // If you need to create a bitmap with a specified resolution, you could directly
            // pass the specified dpiX and dpiY values to RenderTargetBitmap constructor.
            RenderTargetBitmap bmp = new RenderTargetBitmap((Int32)Math.Ceiling(width), (Int32)Math.Ceiling(height), (Double)DeviceHelper.PixelsPerInch(Orientation.Horizontal), (Double)DeviceHelper.PixelsPerInch(Orientation.Vertical), PixelFormats.Pbgra32);

            // If we want to undo the transform, we could use VisualBrush trick.
            if (undoTransformation)
            {
                DrawingVisual dv = new DrawingVisual();
                using (DrawingContext dc = dv.RenderOpen())
                {
                    VisualBrush vb = new VisualBrush(visualToRender);
                    dc.DrawRectangle(vb, null, new Rect(new Point(), new Size(width, height)));
                }
                bmp.Render(dv);
            }
            else
            {
                bmp.Render(visualToRender);
            }

            return bmp;
        }

        /// <summary>
        /// Render a UIElement such that the visual tree is generated, 
        /// without actually displaying the UIElement
        /// anywhere
        /// </summary>
        public static void CreateVisualTree(this UIElement element)
        {
            //var hwndSource = new HwndSource(new HwndSourceParameters()) { RootVisual = windowContent };

            var fixedDoc = new FixedDocument();
            var pageContent = new PageContent();
            var fixedPage = new FixedPage();
            fixedPage.Children.Add(element);
            (pageContent as IAddChild).AddChild(fixedPage);
            fixedDoc.Pages.Add(pageContent);

            var f = new XpsSerializerFactory();
            var w = f.CreateSerializerWriter(new MemoryStream());
            w.Write(fixedDoc);

            fixedPage.Children.Remove(element);
        }

        /// <summary>
        /// Finds a parent of a given item on the visual tree.
        /// </summary>
        /// <typeparam name="T">The type of the queried item.</typeparam>
        /// <param name="child">A direct or indirect child of the
        /// queried item.</param>
        /// <returns>The first parent item that matches the submitted
        /// type parameter. If not matching item can be found, a null
        /// reference is being returned.</returns>
        public static T TryFindParent<T>(this DependencyObject child) where T : DependencyObject
        {
            //get parent item
            DependencyObject parentObject = GetParentObject(child);

            //we've reached the end of the tree
            if (parentObject == null) return null;

            //check if the parent matches the type we're looking for
            T parent = parentObject as T;
            if (parent != null)
            {
                return parent;
            }
            else
            {
                //use recursion to proceed with next level
                return TryFindParent<T>(parentObject);
            }
        }

        /// <summary>
        /// Finds a child of the given item on the visual tree.
        /// </summary>
        /// <typeparam name="T">The type of the queried item.</typeparam>
        /// <param name="parent">A parent of the queried item.</param>
        /// <returns>The first child item that matches the submitted
        /// type parameter. If not matching item can be found, a null
        /// reference is being returned.</returns>
        public static T TryFindChild<T>(this DependencyObject parent) where T : DependencyObject
        {
            for (int i = 0; i < VisualTreeHelper.GetChildrenCount(parent); i++)
            {
                DependencyObject child = VisualTreeHelper.GetChild(parent, i);

                if (child is T)
                {
                    return (T)child;
                }
                else
                {
                    child = TryFindChild<T>(child);
                    if (child != null)
                    {
                        return (T)child;
                    }
                }
            }
            return null;
        }

        /// <summary>
        /// This method is an alternative to WPF's
        /// <see cref="VisualTreeHelper.GetParent"/> method, which also
        /// supports content elements. Keep in mind that for content element,
        /// this method falls back to the logical tree of the element!
        /// </summary>
        /// <param name="child">The item to be processed.</param>
        /// <returns>The submitted item's parent, if available. Otherwise
        /// null.</returns>
        public static DependencyObject GetParentObject(this DependencyObject child)
        {
            if (child == null) return null;

            //handle content elements separately
            ContentElement contentElement = child as ContentElement;
            if (contentElement != null)
            {
                DependencyObject parent = ContentOperations.GetParent(contentElement);
                if (parent != null) return parent;

                FrameworkContentElement fce = contentElement as FrameworkContentElement;
                return fce != null ? fce.Parent : null;
            }

            //also try searching for parent in framework elements (such as DockPanel, etc)
            FrameworkElement frameworkElement = child as FrameworkElement;
            if (frameworkElement != null)
            {
                DependencyObject parent = frameworkElement.Parent;
                if (parent != null) return parent;
            }

            //if it's not a ContentElement/FrameworkElement, rely on VisualTreeHelper
            return VisualTreeHelper.GetParent(child);
        }

        /// <summary>
        /// Tries to locate a given item within the visual tree,
        /// starting with the dependency object at a given position. 
        /// </summary>
        /// <typeparam name="T">The type of the element to be found
        /// on the visual tree of the element at the given location.</typeparam>
        /// <param name="reference">The main element which is used to perform
        /// hit testing.</param>
        /// <param name="point">The position to be evaluated on the origin.</param>
        public static T TryFindFromPoint<T>(UIElement reference, Point point) where T : DependencyObject
        {
            DependencyObject element = reference.InputHitTest(point) as DependencyObject;
            if (element == null) return null;
            else if (element is T) return (T)element;
            else return TryFindParent<T>(element);
        }
    }
}
