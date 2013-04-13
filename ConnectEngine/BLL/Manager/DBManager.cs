using ConnectEngine.BLL.Classes;
using ConnectEngine.DAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Services;

namespace ConnectEngine.BLL.Manager
{
    public class DBManager
    {

        public List<Tables> GetAllDBTables(string dbName)
        {
            List<Tables> allTables = new List<Tables>();
            DatabaseAccess access = new DatabaseAccess();
            try
            {
                allTables = access.GetAllDBTables(dbName);
            }
            catch (Exception excp)
            {
                throw;
            }
            return allTables;
        }
        [WebMethod]
        public List<Columns> GetColumns(string tableName,string dbName)
        {
            List<Columns> allColumns = new List<Columns>();
            DatabaseAccess access = new DatabaseAccess();
            try
            {
                allColumns = access.GetColoumns(tableName,dbName);
            }
            catch (Exception excep)
            {
                throw new Exception("Error in fetching data" + excep);
            }
            return allColumns;
        }

        public DataTable GetResult(string query)
        {
            DatabaseAccess getData = new DatabaseAccess();
            DataTable resultData = new DataTable();
            try
            {
                if (query != null)
                {
                    resultData = getData.GetResult(query);
                }
            }
            catch (Exception)
            {
                throw;
            }
            return resultData;
        }

        public bool CheckNull(string query)
        {
            bool isNull = false;
            if (!string.IsNullOrEmpty(query))
            {
                isNull = true;
            }
            return isNull;
        }
    }
}