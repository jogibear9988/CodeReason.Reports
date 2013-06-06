using System;
using System.Collections.Generic;
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
using ICSharpCode.WpfDesign.Designer.Services;

namespace ReportEditor
{
    /// <summary>
    /// Interaction logic for ToolBoxView.xaml
    /// </summary>
    public partial class ToolBoxView : UserControl
    {
        public ToolBoxView()
        {
            InitializeComponent();

            Style itemContainerStyle = new Style(typeof(ListBoxItem));
            itemContainerStyle.Setters.Add(new EventSetter(PreviewMouseLeftButtonDownEvent, new MouseButtonEventHandler(lstControls_PreviewMouseLeftButtonDown)));
            lstControls.ItemContainerStyle = itemContainerStyle;
        }

        private void lstControls_PreviewMouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            if (sender is ListBoxItem)
            {
                ListBoxItem draggedItem = sender as ListBoxItem;
                draggedItem.IsSelected = true;
                var itm = draggedItem.Content as ToolBoxItem;
                var tool = new CreateComponentTool(itm.Control);
                DragDrop.DoDragDrop(this, tool, DragDropEffects.Copy);
            }
        }
    }
}
