using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Panoptimus
{
    public partial class BrowserWindow : Form
    {
        private ApplicationController applicationController;

        public BrowserWindow()
        {
            InitializeComponent();
        }

        public BrowserWindow(ApplicationController controller)
        {
            applicationController = controller;
            InitializeComponent();
        }

        private void newToolStripMenuItem_Click(object sender, EventArgs e)
        {
            applicationController.NewWindow();
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        private void ValidateMenuItems(object sender, EventArgs e)
        {
            closeAllOtherWindowsToolStripMenuItem.Enabled = (applicationController.BrowserWindowList.Count > 1);
        }

        private void closeAllOtherWindowsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            applicationController.CloseOtherWindows(this);
        }
    }
}
