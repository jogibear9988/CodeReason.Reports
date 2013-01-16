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
using System.Windows.Markup;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace CodeReason.Reports.Math
{
    /// <summary>
    /// Interaction logic for MathMLControl.xaml
    /// </summary>
    public partial class MathMLControl : UserControl
    {
        public string MathML
        {
            get { return (string)GetValue(MathMLProperty); }
            set { SetValue(MathMLProperty, value); }
        }

        public static readonly DependencyProperty MathMLProperty = DependencyProperty.Register("MathML", typeof(string), typeof(MathMLControl), new PropertyMetadata("", OnMathMLChanged));

        private static void OnMathMLChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
        {
            var mode = System.ComponentModel.DesignerProperties.GetIsInDesignMode(d);

            if (!mode)
            {
                var ctl = d as MathMLControl;
                ctl.Content = null;

                if (e.NewValue != null && !string.IsNullOrEmpty(e.NewValue.ToString()))
                {
                    var rd = new StringReader(e.NewValue.ToString());
                    var img = MathMLToSVGviaXSLT.Convert(rd);
                    ctl.Content = img;
                }
            }
        }

        
        public MathMLControl()
        {
            InitializeComponent();
        }        
    }
}
