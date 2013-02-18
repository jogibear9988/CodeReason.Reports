using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Media;
using System.Windows.Media.Imaging;

namespace CodeReason.Reports.Export
{
    public static class FrameworkElementExtensions
    {
        public static RenderTargetBitmap RenderBitmap(this FrameworkElement visualToRender, double quality = 1)
        {
            double scale = (96 * quality) / 96;
            RenderTargetBitmap bmp = new RenderTargetBitmap((int)(scale * (visualToRender.ActualWidth + 1)), (int)(scale * (visualToRender.ActualHeight + 1)), scale * 96, scale * 96, PixelFormats.Default);
            bmp.Render(visualToRender);
            return bmp;
        }
    }
}
