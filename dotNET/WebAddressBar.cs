using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Panoptimus
{
    public partial class WebAddressBar : UserControl
    {
        int certArea = 0;
        int buttonArea = 0;
        int padding = SystemInformation.Border3DSize.Height;

        public WebAddressBar()
        {
            InitializeComponent();
        }

        private void WebAddressBar_Resize(object sender, EventArgs e)
        {
            certArea = (padlockBox.Width + entityName.Width) + (padding * 10);
            buttonArea = (pictureBox.Width + (padding * 4));
            int tboxWidth = this.Width - (certArea + buttonArea);
            Size s = new Size(tboxWidth, this.Height);
            addressBox.Size = s;
            int buttonX = certArea + tboxWidth + (pictureBox.Size.Width / 2);
            Point p = new Point(buttonX, pictureBox.Size.Height);
            pictureBox.Location = p;
            Size cr = this.Size;
            cr.Height -= (padding * 4);
            cr.Width = cr.Height;
            pictureBox.Size = cr;
            padlockBox.Size = cr;
            entityName.Height = this.Height;
            p = padlockBox.Location;
            int yset = ((this.Height / 2) - (padlockBox.Height / 2)) - padding; ;
            p.Y = yset;
            padlockBox.Location = p;
            p = pictureBox.Location;
            p.Y = yset;
            pictureBox.Location = p;
            p.X = certArea;
            p.Y = 0;
            addressBox.Location = p;
        }

        private void WebAddressBar_Load(object sender, EventArgs e)
        {
           
   
        }

        private void WebAddressBar_Paint(object sender, PaintEventArgs e)
        {
            Point p1 = new Point((addressBox.Location.X - (padding * 2)), 0);
            Point p2 = new Point(p1.X, this.Height);
            e.Graphics.DrawLine(Pens.DarkGray, p1, p2);
            p1.X = certArea + addressBox.Width;
            p2.X = p1.X;
            e.Graphics.DrawLine(Pens.DarkGray, p1, p2);
        }
    }
}
