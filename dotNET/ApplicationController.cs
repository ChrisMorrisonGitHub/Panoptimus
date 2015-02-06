using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Panoptimus
{
    public class ApplicationController
    {
        private List<BrowserWindow> windowList;

        /// <summary>
        /// Creates a new instance of the application controller.
        /// </summary>
        public ApplicationController()
        {
            windowList = new List<BrowserWindow>(10);
        }

        /// <summary>
        /// Creates and open a new browser window.
        /// </summary>
        public void NewWindow()
        {
            BrowserWindow newWindow = new BrowserWindow(this);
            windowList.Add(newWindow);
            newWindow.FormClosed += newWindow_FormClosed;
            newWindow.Show();
        }

        void newWindow_FormClosed(object sender, System.Windows.Forms.FormClosedEventArgs e)
        {
            BrowserWindow bw = (BrowserWindow)sender;
            windowList.Remove(bw);
            if (windowList.Count == 0) Application.Exit();
        }

        /// <summary>
        /// Closes all other browser windows leaving only the given window on the screen.
        /// </summary>
        /// <param name="sender"></param>
        public void CloseOtherWindows(BrowserWindow sender)
        {
            List<BrowserWindow> tempList = windowList.GetRange(0, windowList.Count);
            foreach(BrowserWindow bw in tempList)
            {
                if (bw != sender)
                {
                    bw.Close();
                }
            }
        }

        /// <summary>
        /// Gets the list of windows for this application.
        /// </summary>
        public List<BrowserWindow> BrowserWindowList
        {
            get
            {
                return windowList;
            }
        }
    }
}
