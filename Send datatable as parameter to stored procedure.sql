--Step 1 : Create new asp.net web application project. Name it Demo. 

--Step 2 : Include a connection string in the web.config file to your database.
<add name="DBCS"
      connectionString="server=.;database=SampleDB;integrated security=SSPI"/>

--Step 3 : Copy and paste the following HTML in WebForm1.aspx
<asp:Button ID="btnFillDummyData" runat="server" Text="Fill Dummy Data"
    OnClick="btnFillDummyData_Click" />
<br /><br />
<table>
    <tr>
        <td>
            ID : <asp:TextBox ID="txtId1" runat="server"></asp:TextBox>
        </td>
        <td>
            Name : <asp:TextBox ID="txtName1" runat="server"></asp:TextBox>
        </td>
        <td>
            Gender : <asp:TextBox ID="txtGender1" runat="server"></asp:TextBox>
        </td>
    </tr>
    <tr>
        <td>
            ID : <asp:TextBox ID="txtId2" runat="server"></asp:TextBox>
        </td>
        <td>
            Name : <asp:TextBox ID="txtName2" runat="server"></asp:TextBox>
        </td>
        <td>
            Gender : <asp:TextBox ID="txtGender2" runat="server"></asp:TextBox>
        </td>
    </tr>
    <tr>
        <td>
            ID : <asp:TextBox ID="txtId3" runat="server"></asp:TextBox>
        </td>
        <td>
            Name : <asp:TextBox ID="txtName3" runat="server"></asp:TextBox>
        </td>
        <td>
            Gender : <asp:TextBox ID="txtGender3" runat="server"></asp:TextBox>
        </td>
    </tr>
    <tr>
        <td>
            ID : <asp:TextBox ID="txtId4" runat="server"></asp:TextBox>
        </td>
        <td>
            Name : <asp:TextBox ID="txtName4" runat="server"></asp:TextBox>
        </td>
        <td>
            Gender : <asp:TextBox ID="txtGender4" runat="server"></asp:TextBox>
        </td>
    </tr>
    <tr>
        <td>
            ID : <asp:TextBox ID="txtId5" runat="server"></asp:TextBox>
        </td>
        <td>
            Name : <asp:TextBox ID="txtName5" runat="server"></asp:TextBox>
        </td>
        <td>
            Gender : <asp:TextBox ID="txtGender5" runat="server"></asp:TextBox>
        </td>
    </tr>
</table>
<br />
<asp:Button ID="btnInsert" runat="server" Text="Insert Employees"
    OnClick="btnInsert_Click" />

--Step 4 : Copy and paste the following code in the code-behind file
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace Demo
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        { }

        private DataTable GetEmployeeData()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("Id");
            dt.Columns.Add("Name");
            dt.Columns.Add("Gender");

            dt.Rows.Add(txtId1.Text, txtName1.Text, txtGender1.Text);
            dt.Rows.Add(txtId2.Text, txtName2.Text, txtGender2.Text);

 
            dt.Rows.Add(txtId3.Text, txtName3.Text, txtGender3.Text);
            dt.Rows.Add(txtId4.Text, txtName4.Text, txtGender4.Text);
            dt.Rows.Add(txtId5.Text, txtName5.Text, txtGender5.Text);

            return dt;
        }

        protected void btnInsert_Click(object sender, EventArgs e)
        {
            string cs = ConfigurationManager.ConnectionStrings["DBCS"].ConnectionString;
            using (SqlConnection con = new SqlConnection(cs))
            {
                SqlCommand cmd = new SqlCommand("spInsertEmployees", con);
                cmd.CommandType = CommandType.StoredProcedure;

                SqlParameter paramTVP = new SqlParameter()
                {
                    ParameterName = "@EmpTableType",
                    Value = GetEmployeeData()
                };
                cmd.Parameters.Add(paramTVP);

                con.Open();
                cmd.ExecuteNonQuery();
                con.Close();
            }
        }

        protected void btnFillDummyData_Click(object sender, EventArgs e)
        {
            txtId1.Text = "1";
            txtId2.Text = "2";
            txtId3.Text = "3";
            txtId4.Text = "4";
            txtId5.Text = "5";

            txtName1.Text = "John";
            txtName2.Text = "Mike";
            txtName3.Text = "Sara";
            txtName4.Text = "Pam";
            txtName5.Text = "Todd";

            txtGender1.Text = "Male";
            txtGender2.Text = "Male";
            txtGender3.Text = "Female";
            txtGender4.Text = "Female";
            txtGender5.Text = "Male";
        }
    }
}