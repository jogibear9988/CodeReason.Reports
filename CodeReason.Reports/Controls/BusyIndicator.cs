using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Shapes;
using System.Windows.Threading;

namespace CodeReason.Reports.Controls
{
    public class BusyIndicator : ContentControl
    {
        private ContentPresenter presContent;
        private ContentControl presBusyContent;


        static BusyIndicator()
        {
            DefaultStyleKeyProperty.OverrideMetadata(typeof(BusyIndicator), new FrameworkPropertyMetadata(typeof(BusyIndicator)));
        }

        public override void OnApplyTemplate()
        {
            base.OnApplyTemplate();

            presContent = (ContentPresenter)this.GetTemplateChild("content");
            presBusyContent = (ContentControl)this.GetTemplateChild("busycontent");

            refreshState();
        }

        public static readonly DependencyProperty IsBusyProperty = DependencyProperty.Register("IsBusy", typeof(bool), typeof(BusyIndicator), new PropertyMetadata(false, OnIsBusyChanged));

        public bool IsBusy
        {
            get
            {
                return (bool)this.GetValue(IsBusyProperty);
            }
            set
            {
                this.SetValue(IsBusyProperty, value);
            }
        }

        private static void OnIsBusyChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
        {
            ((BusyIndicator)d).refreshState();
        }

        private void refreshState()
        {
            if (presContent != null)
            {
                if (this.IsBusy)
                {
                    presBusyContent.Visibility = Visibility.Visible;
                    presContent.Visibility = Visibility.Visible;
                }
                else
                {
                    presBusyContent.Visibility = Visibility.Collapsed;
                    presContent.Visibility = Visibility.Visible;
                }
            }
        }

        public static readonly DependencyProperty BusyContentProperty = DependencyProperty.Register("BusyContent", typeof(object), typeof(BusyIndicator), new PropertyMetadata(null));

        public object BusyContent
        {
            get
            {
                return (object)this.GetValue(BusyContentProperty);
            }
            set
            {
                this.SetValue(BusyContentProperty, value);
            }
        }        
    }
}
