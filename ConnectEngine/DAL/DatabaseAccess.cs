using ConnectEngine.BLL.Classes;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;

namespace ConnectEngine.DAL
{
    public class DatabaseAccess : DatabaseConnection
    {
        private string commandString = null;
        [NonSerialized]
        private SqlDataReader getData = null;

        public List<Tables> GetAllDBTables(string databaseName)
        {
            List<Tables> allTable = new List<Tables>();
            try
            {
                string query = "USE " + databaseName;
                GetSqlConn.Open();
                commandString = string.Format(query+" SELECT TABLE_NAME AS Table_name FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'");
                GetSqlCommand.CommandText = commandString;
                GetSqlCommand.Parameters.Clear();
                getData = GetSqlCommand.ExecuteReader();
                while (getData.Read())
                {
                    Tables aTable = new Tables();
                    aTable.TableName = getData["Table_name"].ToString();
                    allTable.Add(aTable);
                }
            }
            catch (Exception exp)
            {
                throw new Exception("Error while fetching data" + exp);
            }
            finally
            {
                GetSqlConn.Close();
            }
            return allTable;
        }
        [WebMethod]
        public List<Columns> GetColoumns(string tableName,string dbName)
        {
            List<Columns> allColoumns = new List<Columns>();
            string database = "USE " + dbName;
            try
            {
                GetSqlConn.Open();
                commandString = string.Format(database+" select COLUMN_NAME,DATA_TYPE from information_schema.columns where table_name = @tableName");
                GetSqlCommand.CommandText = commandString;
                GetSqlCommand.Parameters.Clear();
                GetSqlCommand.Parameters.Add("@tableName", SqlDbType.NVarChar);
                GetSqlCommand.Parameters["@tableName"].Value = tableName;
                getData = GetSqlCommand.ExecuteReader();
                while (getData.Read())
                {
                    Columns aColoumn = new Columns();
                    aColoumn.ColName = getData["COLUMN_NAME"].ToString();
                    aColoumn.DataType = getData["DATA_TYPE"].ToString();
                    allColoumns.Add(aColoumn);
                }
            }
            catch (Exception exp)
            {
                throw new Exception("Error while fetching data" + exp);
            }
            finally
            {
                GetSqlConn.Close();
            }
            return allColoumns;
        }

        public DataTable GetResult(string query)
        {
            DataTable resultTable = new DataTable();
            try
            {
                GetSqlConn.Open();
                GetSqlCommand.CommandText = query;
                SqlDataAdapter getData = new SqlDataAdapter(GetSqlCommand);
                getData.Fill(resultTable);
            }
            catch (Exception ex)
            {
                throw new Exception("Error fetching data"+ex);
            }
            finally
            {
                GetSqlConn.Close();
            }
            return resultTable;
        }
    }
}