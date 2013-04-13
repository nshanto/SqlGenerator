<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SearchDB.aspx.cs" Inherits="ConnectEngine.SearchDB" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Sql query generator</title>
    <script type="text/javascript" src="Scripts/jquery-1.9.1.min.js"></script>
    <script type="text/javascript" src="Scripts/jquery.selectboxes.min.js"></script>
    <link href="Styles/styles.css" rel="stylesheet" />
    <script type="text/javascript">
        var queryString;
        var tables;
        var tLength;
        var numAndDate = [
                "bigint",
                "bit",
                "decimal",
                "int",
                "money",
                "numeric",
                "smallint",
                "smallmoney",
                "tinyint",
                "float",
                "real"
        ];
        var numAndDateCondition = [
                "=",
                "<>",
                ">",
                "<",
                ">=",
                "<=",
                "BETWEEN"
        ];
        var stringCondition = [
                "LIKE",
                "NOT LIKE",
                "<>",
                "=",
                "BETWEEN"
        ];
        function GetColumnName()
        {
            $('#wherePortion').empty();
            queryString = "";
            $('#queryTextBox').val(queryString);
            $.ajax({
                type: "POST",
                url: "/SearchDB.aspx/GetCoumls",
                data: "{tableName: '" + $('#tableNameDropDown').val() + "',dbName: '" + $('#dbNameDropDown').val() + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    tables = response.d;
                    tLength = tables.length;
                    $("#checkList").empty();
                    $("#checkList").append('<p>SELECT :</p>');
                    $("#checkList").append('<input class="checkTable" type="checkbox"' +
                        'name="tableName" id="test" value="*" onchange="testCheck()" />All');
                    for (var i = 0; i < tLength; i++) {
                        $("#checkList").append('<input class="checkTable" type="checkbox"' +
                        'name="tableName" value="'+tables[i].ColName+'"'+ '" onchange="testCheck()"'+
                        '"/>' + tables[i].ColName);
                    }
                    $("#checkList").append('<br/><input class="dist" id="distinct" type="checkbox"' +
                       'name="distinct" disabled="disabled" value="DISTINCT"' + '" onchange="testCheck()"' +
                       '"/>' + 'DISTINCT');
                }
            });
            
        }
        $(document).ready(function () {
            
        });
        function selectAll(elm) {
            if (elm.val() == "*") {
                $('.checkTable').prop("checked", "checked");
            } 
        }
        function GetTableName()
        {
            return $('#tableNameDropDown').val();
        }
        
        function testCheck()
        {
            var checkAny = false;
            $('#distinct').attr('disabled', true);
            $('#whereButton').attr('disabled', true);
            queryString = "";
            var str = [];
            $(':input[name="distinct"]:checked').each(function () {
                queryString = "SELECT DISTINCT "
                //alert($(this).val());
            });
            $(':input[name="tableName"]:checked').each(function () {
                checkAny = true;
                $('#distinct').attr('disabled', false);
                $('#whereButton').attr('disabled', false);
                if (queryString.length < 1)
                {
                    queryString = "SELECT ";
                }
                selectAll($(this));
                if ($(this).val() == "*") {
                    str = [];
                    str.push($(this).val());
                    return false;
                }
                else
                {
                    str.push($(this).val());
                }
                //alert($(this).val());
            });
            queryString += str;
            if(queryString.length > 0)
            queryString += " FROM " + GetTableName();
            //$('#queryTextBox').val(queryString);
            if (checkAny == false) {
                queryString = "";
            }
            $("#<%=queryTextBox.ClientID%>").val(queryString);
            
        }
        function WhereButtonClick()
        {
            //var all = "";
            $('#wherePortion').empty();
            $('#wherePortion').append('<p>'+
                '<label>Column Name:</label><br />'+
                '<select id="columnDropDown" onchange="GetExpression()"></select>' +
            '</p>');
            $('#wherePortion').append('<p>' +
                '<label>Condition:</label><br />' +
                '<select id="conditionDropDown" disabled="disabled" onchange="EnableText()"></select>' +
            '</p>');
            $('#wherePortion').append('<p>' +
                '<label>Value:</label><br />' +
                '<input id="valueText" type="text" disabled="disabled" onblur="TakeData()" />' +
            '</p><br/><hr/>');
            var val = "";
            var text = "";
            $('#columnDropDown').removeOption(/./).addOption('', '---Please Select---');
            for (var i = 0; i < tLength; i++) {
                val = tables[i].DataType;
                text = tables[i].ColName;
                $('#columnDropDown').append(new Option(text, val, true, true));
            }
        }
        function GetExpression()
        {
            $('#conditionDropDown').attr('disabled',false);
            $('#conditionDropDown').empty();
            if (jQuery.inArray($("#columnDropDown option:selected").val(), numAndDate) > 0) {
                
                var itemNumber = numAndDateCondition.length;
                for (var i = 0; i < itemNumber; i++) {
                    $('#conditionDropDown').append(new Option(numAndDateCondition[i], numAndDateCondition[i], true, true));
                }
            }
            else
            {
                var itemNumber = stringCondition.length;
                for (var i = 0; i < itemNumber; i++) {
                    $('#conditionDropDown').append(new Option(stringCondition[i], stringCondition[i], true, true));
                }
            }
        }
        function AndOrButton(buttonType)
        {
            alert(buttonType);
        }
        function TakeData()
        {
            if ($('#valueText').val().length > 0) {
                queryString = queryString.split(' WHERE')[0];
                queryString = queryString + " WHERE " + $('#columnDropDown option:selected').text() +" "+ $('#conditionDropDown').val() + " " + $('#valueText').val();
                $("#<%=queryTextBox.ClientID%>").val(queryString);
            }
            else
            {
                alert("Incomplete Where clause");
            }
        }
        function EnableText()
        {
            $('#valueText').attr('disabled',false);
        }
    </script>
    <noscript>
        <meta http-equiv="refresh" content="0; url=JavascriptDisabled.html">
    </noscript>

</head>
<body>
    <form id="form1" runat="server">
        <h1> SQL Generator</h1>
        <div id="mainBody">
            <div id="mainContents">
                <asp:Label ID="sqlStatus" runat="server" Text=""></asp:Label>
                <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
                <div>
                    <asp:Button ID="connect" CssClass="buttonStyle" runat="server" Text="Establish Connection" OnClick="connect_Click" />
                    <br />
                    <asp:DropDownList ID="dbNameDropDown" runat="server" OnSelectedIndexChanged="dbNameDropDown_SelectedIndexChanged" AutoPostBack="True">
                    </asp:DropDownList>
                    <hr />
                </div>
                <div class="selectQuery">
                    <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
                       <ContentTemplate>
                           <div>
                               <p>From :</p>
                               <asp:DropDownList ID="tableNameDropDown" runat="server"></asp:DropDownList>
                               <div id="checkList" class="selectQuery">
                               </div>
                           </div>
                           </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="dbNameDropDown" EventName="SelectedIndexChanged" />
                        </Triggers>
                    </asp:UpdatePanel>
                           <br />
                           <hr />
                           <input id="whereButton" type="button" value="WHERE" disabled="disabled" onclick="WhereButtonClick()" />
                           <div id ="wherePortion" class="selectQuery">
                           </div>
                           <br />
                            <input id="andButton" type="button" value="AND" onclick="AndOrButton($(this).val())" />
                            <input id="orButton" type="button" value="OR" onclick="AndOrButton($(this).val())" />
                           <div id="andOrPortion">
                           </div>
                    <br />
                    <hr />
                    <div id="outputText">
                        <p>Query string :</p>
                        <asp:TextBox ID="queryTextBox" runat="server" Height="46px" TextMode="MultiLine" Width="442px" ViewStateMode="Enabled"></asp:TextBox>
                        <asp:Button ID="resultButton" runat="server" Text="Get Result" OnClick="resultButton_Click" />
                    </div>
                    <asp:UpdatePanel ID="UpdatePanel2" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:GridView ID="resultGrid" runat="server"></asp:GridView>
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="resultButton" EventName="Click" />
                        </Triggers>
                    </asp:UpdatePanel>
                 
                </div>           
            </div>
         </div>
    </form>
</body>
</html>
