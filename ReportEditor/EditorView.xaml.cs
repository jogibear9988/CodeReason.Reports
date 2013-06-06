using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Xml;
using ICSharpCode.WpfDesign;
using ICSharpCode.WpfDesign.Designer;
using ICSharpCode.WpfDesign.Designer.Services;
using ICSharpCode.WpfDesign.Designer.Xaml;

namespace ReportEditor
{
    /// <summary>
    /// Interaction logic for EditorView.xaml
    /// </summary>
    public partial class EditorView : UserControl
    {
        private static string baseScreen =
            "<Canvas x:Name=\"rootElement\" Background=\"White\" xmlns=\"http://schemas.microsoft.com/winfx/2006/xaml/presentation\"\r\n        xmlns:x=\"http://schemas.microsoft.com/winfx/2006/xaml\">\r\n    </Canvas>";

        private DesignSurfaceWithoutZoom[] designSurfaces;

        public EditorView()
        {
            InitializeComponent();

            designSurfaces = new[] {reportHeader, pageHeader, page, pageFooter, reportFooter};
            var xmlReader = XmlReader.Create(new StringReader(baseScreen));
            reportHeader.LoadDesigner(xmlReader, null);
            xmlReader = XmlReader.Create(new StringReader(baseScreen));
            pageHeader.LoadDesigner(xmlReader, null);
            xmlReader = XmlReader.Create(new StringReader(baseScreen));
            page.LoadDesigner(xmlReader, null);
            xmlReader = XmlReader.Create(new StringReader(baseScreen));
            pageFooter.LoadDesigner(xmlReader, null);
            xmlReader = XmlReader.Create(new StringReader(baseScreen));
            reportFooter.LoadDesigner(xmlReader, null);

            foreach (var designSurfaceWithoutZoom in designSurfaces)
            {
                designSurfaceWithoutZoom.PreviewDragOver += designSurfaceWithoutZoom_DragOver;
                designSurfaceWithoutZoom.Drop += designSurfaceWithoutZoom_Drop;
            }                      
        }

        void designSurfaceWithoutZoom_Drop(object sender, DragEventArgs e)
        {
            foreach (var designSurfaceWithoutZoom in designSurfaces)
            {
                designSurfaceWithoutZoom.DesignContext.Services.Tool.CurrentTool =
                    designSurfaceWithoutZoom.DesignContext.Services.Tool.PointerTool;
            }
        }

        void designSurfaceWithoutZoom_DragOver(object sender, DragEventArgs e)
        {
            var srv = sender as DesignSurfaceWithoutZoom;
            if (e.Data.GetDataPresent("SelectedTag"))
                return;
            var data = e.Data.GetData("ICSharpCode.WpfDesign.Designer.Services.CreateComponentTool") as CreateComponentTool;
            srv.DesignContext.Services.Tool.CurrentTool = data;
        }
    }
}
