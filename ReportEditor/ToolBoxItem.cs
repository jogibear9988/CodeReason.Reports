using System;
using System.ComponentModel;
using System.Windows.Media;

namespace ReportEditor
{
    public class ToolBoxItem : INotifyPropertyChanged
    {
        public ToolBoxItem(Type Control)
        {
            this.Control = Control;
        }

        public ToolBoxItem()
        { }

        public event PropertyChangedEventHandler PropertyChanged;

        protected virtual void OnPropertyChanged(string propertyName)
        {
            PropertyChangedEventHandler handler = this.PropertyChanged;
            if (handler != null)
            {
                handler(this, new PropertyChangedEventArgs(propertyName));
            }
        }

        public Type Control { get; set; }

        public ImageSource ToolBoxImage { get; set; }

        public string GroupName { get; set; }

        public string Name
        {
            get
            {
                return Control.Name;
            }
        }
    }
}
