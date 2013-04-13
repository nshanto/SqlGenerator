using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace ConnectEngine.DAL
{
    public class DatabaseConnection
    {
        [NonSerialized]
        private SqlConnection sqlConn;
        [NonSerialized]
        private SqlCommand sqlCommand;

        public DatabaseConnection()
        {
            sqlConn = new SqlConnection(ConfigurationManager.AppSettings["connectionString"]);
            sqlCommand = new SqlCommand();
        }

        public SqlConnection GetSqlConn
        {
            get
            {
                return sqlConn;
            }
        }

        public SqlCommand GetSqlCommand
        {
            get
            {
                sqlCommand.Connection = sqlConn;
                return sqlCommand;
            }
        }
    }
}