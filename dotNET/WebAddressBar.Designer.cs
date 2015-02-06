namespace Panoptimus
{
    partial class WebAddressBar
    {
        /// <summary> 
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary> 
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Component Designer generated code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(WebAddressBar));
            this.addressBox = new System.Windows.Forms.TextBox();
            this.pictureBox = new System.Windows.Forms.PictureBox();
            this.padlockBox = new System.Windows.Forms.PictureBox();
            this.entityName = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.padlockBox)).BeginInit();
            this.SuspendLayout();
            // 
            // addressBox
            // 
            this.addressBox.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.addressBox.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.addressBox.Location = new System.Drawing.Point(79, 0);
            this.addressBox.Name = "addressBox";
            this.addressBox.Size = new System.Drawing.Size(289, 16);
            this.addressBox.TabIndex = 0;
            this.addressBox.WordWrap = false;
            // 
            // pictureBox
            // 
            this.pictureBox.BackColor = System.Drawing.SystemColors.Window;
            this.pictureBox.Location = new System.Drawing.Point(376, 2);
            this.pictureBox.Margin = new System.Windows.Forms.Padding(0);
            this.pictureBox.Name = "pictureBox";
            this.pictureBox.Size = new System.Drawing.Size(16, 16);
            this.pictureBox.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.pictureBox.TabIndex = 1;
            this.pictureBox.TabStop = false;
            // 
            // padlockBox
            // 
            this.padlockBox.Image = ((System.Drawing.Image)(resources.GetObject("padlockBox.Image")));
            this.padlockBox.Location = new System.Drawing.Point(2, 2);
            this.padlockBox.Margin = new System.Windows.Forms.Padding(0);
            this.padlockBox.Name = "padlockBox";
            this.padlockBox.Size = new System.Drawing.Size(16, 16);
            this.padlockBox.SizeMode = System.Windows.Forms.PictureBoxSizeMode.Zoom;
            this.padlockBox.TabIndex = 2;
            this.padlockBox.TabStop = false;
            // 
            // entityName
            // 
            this.entityName.AutoEllipsis = true;
            this.entityName.AutoSize = true;
            this.entityName.FlatStyle = System.Windows.Forms.FlatStyle.System;
            this.entityName.Font = new System.Drawing.Font("Segoe UI", 6.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.entityName.ForeColor = System.Drawing.SystemColors.ControlText;
            this.entityName.Location = new System.Drawing.Point(22, 2);
            this.entityName.Name = "entityName";
            this.entityName.Size = new System.Drawing.Size(45, 12);
            this.entityName.TabIndex = 3;
            this.entityName.Text = "Unknown";
            // 
            // WebAddressBar
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.Window;
            this.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.Controls.Add(this.entityName);
            this.Controls.Add(this.padlockBox);
            this.Controls.Add(this.pictureBox);
            this.Controls.Add(this.addressBox);
            this.Name = "WebAddressBar";
            this.Size = new System.Drawing.Size(400, 20);
            this.Load += new System.EventHandler(this.WebAddressBar_Load);
            this.Paint += new System.Windows.Forms.PaintEventHandler(this.WebAddressBar_Paint);
            this.Resize += new System.EventHandler(this.WebAddressBar_Resize);
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.padlockBox)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox addressBox;
        private System.Windows.Forms.PictureBox pictureBox;
        private System.Windows.Forms.PictureBox padlockBox;
        private System.Windows.Forms.Label entityName;
    }
}
