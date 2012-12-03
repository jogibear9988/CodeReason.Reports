using System.Threading;
using System.Windows.Threading;

namespace CodeReason.Reports
{
    /// <summary>
    /// Extension methods
    /// </summary>
    public static class ExtensionMethods
    {
        /// <summary>
        /// DoEvents for WPF
        /// </summary>
        /// <param name="dispatcher">dispatcher</param>
        public static void DoEvents(this Dispatcher dispatcher)
        {
            DispatcherFrame f = new DispatcherFrame();
            dispatcher.BeginInvoke(DispatcherPriority.Background,
            (SendOrPostCallback)delegate(object arg)
            {
                DispatcherFrame fr = arg as DispatcherFrame;
                if (fr != null) fr.Continue = false;
            }, f);
            Dispatcher.PushFrame(f);
        }
    }
}
