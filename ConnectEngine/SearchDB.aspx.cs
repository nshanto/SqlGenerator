using ConnectEngine.DAL;
using Microsoft.SqlServer.Management.Smo;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using ConnectEngine.BLL.Classes;
using ConnectEngine.BLL.Manager;
using System.Web.Services;
using System.Data;
using System.ServiceProcess;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace ConnectEngine
{
    public partial class SearchDB : System.Web.UI.Page
    {
        DBManager manager = new DBManager();
        protected void Page_Load(object sender, EventArgs e)
        {
            //decorating css properties
            //StylesAttributeSet();
            connect.Enabled = false;
            dbNameDropDown.Enabled = false;
            tableNameDropDown.Enabled = false;
            tableNameDropDown.Attributes.Add("onchange", "GetColumnName()");

            string myServiceName = "MSSQL$SQLEXPRESS"; //service name of SQL Server Express
            string status; //service status (For example, Running or Stopped)

            Console.WriteLine("Service: " + myServiceName);

            //display service status: For example, Running, Stopped, or Paused
            ServiceController mySC = new ServiceController(myServiceName);

            try
            {
                status = mySC.Status.ToString();
                if(status == "Running")
                connect.Enabled = true;
            }
            catch (Exception ex)
            {
                sqlStatus.Text = "Service not found!!!";
                return;
            }

            //display service status: For example, Running, Stopped, or Paused
            sqlStatus.Text = "Service status : " + status;

            //if service is Stopped or StopPending, you can run it with the following code.
            if (mySC.Status.Equals(ServiceControllerStatus.Stopped) | mySC.Status.Equals(ServiceControllerStatus.StopPending))
            {
                try
                {
                    mySC.Start();
                    mySC.WaitForStatus(ServiceControllerStatus.Running);
                    connect.Enabled = true;
                }
                catch (Exception ex)
                {
                    sqlStatus.Text = "Error in starting the service: " + ex.Message;
                }

            }
            return;

        }

        protected void connect_Click(object sender, EventArgs e)
        {
            try
            {
                string dbName = string.Format(@".\SQLEXPRESS");
                List<string> cboDBs = new List<string>();
                cboDBs.Add("---Select a database---");
                Microsoft.SqlServer.Management.Smo.Server server =
                new Microsoft.SqlServer.Management.Smo.Server(dbName);
                foreach (Database db in server.Databases)
                {
                    cboDBs.Add(db.Name);
                }
                dbNameDropDown.DataSource = cboDBs;
                dbNameDropDown.DataBind();
                dbNameDropDown.Enabled = true;
            }
            catch (Exception exep)
            {
                throw new Exception("Could not connect to database engine,Please check connection"+exep);
            }
            
        }

        protected void dbNameDropDown_SelectedIndexChanged(object sender, EventArgs e)
        {
            //StylesAttributeSet();
            List<Tables> allTables = new List<Tables>();
            try
            {
                allTables = manager.GetAllDBTables(dbNameDropDown.SelectedValue);
                tableNameDropDown.Enabled = true;
            }
            catch (Exception ex)
            {
                throw new Exception("Error occured during fetching table name"+ex);
            }
            tableNameDropDown.DataSource = allTables;
            tableNameDropDown.DataValueField = "TableName";
            tableNameDropDown.DataBind();
            
        }
        [WebMethod]
        public static List<Columns> GetCoumls(string tableName,string dbName)
        {
            List<Columns> allColumns = new List<Columns>();
            DBManager manager = new DBManager();
            try
            {
                allColumns = manager.GetColumns(tableName,dbName);
            }
            catch (Exception excep)
            {
                throw new Exception("Error in fetching data" + excep);
            }
            return allColumns;
        }

        protected void resultButton_Click(object sender, EventArgs e)
        {
            
            DataTable resultData = new DataTable();
            string query = "";
            bool checkData = false;
            string text = queryTextBox.Text;
            try
            {
                checkData = manager.CheckNull(text);
                if (checkData)
                {
                    query = "USE " + dbNameDropDown.SelectedValue + " " + text;
                    resultData = manager.GetResult(query);
                    resultGrid.DataSource = resultData;
                    resultGrid.DataBind();
                }
            }
            catch (Exception excp)
            {
                throw new Exception("Error fetching data"+excp);
            }
        }

        protected void StylesAttributeSet()
        {
            //var dropDownLists = AllControls.Controls.OfType<DropDownList>();
            //foreach (var dropDownList in dropDownLists)
            //{
            //    dropDownList.Attributes.Add("class", "dropDownListStyles");
            //}

            //var buttons = AllControls.Controls.OfType<Button>();
            //foreach (var button in buttons) 
            //{
            //    button.Attributes.Add("class", "buttonStyles");
            //}
        }
    }
}