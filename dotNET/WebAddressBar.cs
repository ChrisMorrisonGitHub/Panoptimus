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
        const float BUTTON_WIDTH = 32.00f;
        const float CERT_AREA = 60.00f;

        public WebAddressBar()
        {
            InitializeComponent();
        }

        private void WebAddressBar_Resize(object sender, EventArgs e)
        {

        }

        private void WebAddressBar_Load(object sender, EventArgs e)
        {

        }
    }
}
