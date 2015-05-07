
// luaTestToolDlg.cpp : implementation file
//

#include "stdafx.h"
#include "luaTestTool.h"
#include "luaTestToolDlg.h"
#include "afxdialogex.h"
#include "fstream"

//load 3rd tools
extern "C"
#include "lua.hpp"
#include "json/json.h"
#include "RyeolHttpClient.h"

//namespace
using namespace Json;
using namespace Ryeol ;

//import 3rd lib by micro command
#pragma comment(lib, "lua5.1.lib")

//some global params
lua_State *lua;					//a variable point to lua 	
Json::Value swapInfo;
Json::Value headsInfo;
Json::Value responseData;
Json::Value actionParams;
CString responseBody;

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CAboutDlg dialog used for App About

class CAboutDlg : public CDialogEx
{
public:
	CAboutDlg();

// Dialog Data
	enum { IDD = IDD_ABOUTBOX };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

// Implementation
protected:
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialogEx(CAboutDlg::IDD)
{
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialogEx)
END_MESSAGE_MAP()


// CluaTestToolDlg dialog




CluaTestToolDlg::CluaTestToolDlg(CWnd* pParent /*=NULL*/)
	: CDialogEx(CluaTestToolDlg::IDD, pParent)
	, m_Edit_ActionName_str(_T(""))
	, m_EditBrowse_SelectFile_str(_T(""))
	, m_Edit_SourceType_str(_T(""))
	, m_Edit_Params_str(_T(""))
	, m_Edit_ServerCmd_str(_T(""))
	, m_Combo_Action_str(_T(""))
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
	lua2app = _T("");
	app2lua = _T("");
}

void CluaTestToolDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_EditBrowse_SelectFile, m_EditBrowse_SelectFile);
	DDX_Control(pDX, IDC_Edit_ActionName, m_Edit_ActionName);
	DDX_Text(pDX, IDC_Edit_ActionName, m_Edit_ActionName_str);
	DDX_Text(pDX, IDC_EditBrowse_SelectFile, m_EditBrowse_SelectFile_str);
	DDX_Text(pDX, IDC_Edit_SourceType, m_Edit_SourceType_str);
	DDX_Text(pDX, IDC_Edit_Params, m_Edit_Params_str);
	DDX_Text(pDX, IDC_Edit_ServerCmd, m_Edit_ServerCmd_str);
	DDX_CBString(pDX, IDC_COMBO_Action, m_Combo_Action_str);
	DDX_Control(pDX, IDC_COMBO_Action, m_Combo_Action);
}

BEGIN_MESSAGE_MAP(CluaTestToolDlg, CDialogEx)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDOK, &CluaTestToolDlg::OnBnClickedOk)
//	ON_EN_SETFOCUS(IDC_Edit_ServerCmd, &CluaTestToolDlg::OnEnSetfocusEditServercmd)
//	ON_EN_SETFOCUS(IDC_Edit_ActionName, &CluaTestToolDlg::OnEnSetfocusEditActionname)
//	ON_EN_SETFOCUS(IDC_EditBrowse_SelectFile, &CluaTestToolDlg::OnEnSetfocusEditbrowseSelectfile)
//ON_CBN_SELCHANGE(IDC_COMBO_Action, &CluaTestToolDlg::OnCbnSelchangeComboAction)
END_MESSAGE_MAP()

//combo控件初始化,从config.txt读取参数
bool CluaTestToolDlg::actionListInit()
{
	std::ifstream file;
	file.open("config.txt");
	if (!file)
	{
		AfxMessageBox("config.txt open failed!");
		return false;
	}

	Json::Reader reader;
	Json::Value  root;
	if (!reader.parse(file, root, false))  
	{
		AfxMessageBox("parse json data failed!");
		return false;
	}

	int itemSize;
	if (itemSize = root["action"].size(),itemSize == 0)
	{
		AfxMessageBox("there are no \"action\" items");
		return false;
	}

	//读入action，并添加至Combo控件
	CString code;
	for (int i = 0; i < itemSize; i++)
	{
		code = root["action"][i].asCString();
		m_Combo_Action.AddString(code);
	}

	//若params不为空，则将其读入内存以备用
	if (!root["params"].isNull())
	{
		actionParams = root["params"];
	}

	return true;
}
// CluaTestToolDlg message handlers

BOOL CluaTestToolDlg::OnInitDialog()
{
	CDialogEx::OnInitDialog();

	// Add "About..." menu item to system menu.

	// IDM_ABOUTBOX must be in the system command range.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		BOOL bNameValid;
		CString strAboutMenu;
		bNameValid = strAboutMenu.LoadString(IDS_ABOUTBOX);
		ASSERT(bNameValid);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon
	// TODO: Add extra initialization here
	//open lua
	lua = lua_open (); 
	if(!lua)
	{
		const char* pErr = lua_tostring(lua, -1);
		AfxMessageBox(pErr);
	}

	//open lua lib
	luaL_openlibs(lua);

	//设置控件初始值
	m_EditBrowse_SelectFile_str	= "D:/Users/sjlv/Documents/Visual Studio 2010/Projects/luaTestTool/luaTestTool/luaSrc/train_train.lua";
	m_Edit_ActionName_str		= "mobileinit";
	m_Edit_SourceType_str		= "";
	m_Edit_Params_str			= "\"\'\'\"";
	//m_Edit_ServerCmd_str		= "通过分号来分割，若只有一个ServerCmd，则这栏可以不填";
	m_Edit_ServerCmd_str		= "aa;bb;cc;dd";
	UpdateData(FALSE);

	//combo控件初始化,从config.txt读取参数
	if (!actionListInit())
	{
		AfxMessageBox("Combo Control Init Failed!");
		return FALSE;
	}
	

	return TRUE;  // return TRUE  unless you set the focus to a control
}

void CluaTestToolDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialogEx::OnSysCommand(nID, lParam);
	}
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CluaTestToolDlg::OnPaint()
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialogEx::OnPaint();
	}
}

// The system calls this function to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CluaTestToolDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}

//用Json::toStyledString()这个函数出来的字符串与我们理解的有点出入：
//1、无论是key还是value都会带上一对引号，2、在最后多个单引号。
//实际上出来的字符串是这样的"value"'
CString trim(std::string in)
{
	CString out = in.c_str();
	out.Delete(-1, 1);				//去掉前面的一个引号
	out.Delete(out.GetLength()-2, 2);//去掉后面的两个引号
	return out;
}

//传入参数，运行Lua脚本
CString runLuaScript(CString actionName, CString sourceType, CString jsonParams, CString fileName)
{
	//打开文件
	if(luaL_dofile(lua, fileName)){
		// 加载失败
		const char* pErr = lua_tostring(lua,-1);
		AfxMessageBox(pErr);
		return NULL;
	}

	//将入口参数及其参数压入交互栈
	lua_getglobal(lua, "doParser");
	lua_pushstring(lua, sourceType);
	lua_pushstring(lua, actionName);
	lua_pushstring(lua, jsonParams);

	if(lua_pcall(lua, 3, 1, 0) != 0){
		const char *pErr = lua_tostring(lua, -1); 
		AfxMessageBox(pErr);
		return NULL;
	}
	CString rst = lua_tostring(lua, -1);
	//用完lua的时候，调用下面一句来关闭lua库：
	//lua_close (lua);
	return rst;
}

//解析Lua返回值，并缓存swapInfo至临时文件
void decodeJson(CString lua2app)
{
	Json::Reader reader;  
	Json::Value root;  

	// reader将Json字符串解析到root，root将包含Json里所有子元素
	if (!reader.parse(lua2app.GetBuffer(0), root))    
	{
		AfxMessageBox("parse failed");
		return;
	}

	//获取状态位
	if(!(root["code"].asInt())) 
	{
		AfxMessageBox("code < 0, some error happens!");
		return;
	}

	swapInfo = root["swapInfo"];
	headsInfo = root["headsInfo"];	

	return;
}

//从临时文件读取服务器返回数据并打包成jsonParams供Lua使用
CString encodeJson(CString extraParams)
{
#if 0
	//从临时文件读取数据
	try
	{	//若文件不存在，则会抛出异常
		CStdioFile file("datafile.txt", CFile::modeNoTruncate|CFile::modeRead);
		CString responseBody,buffer;
		responseBody = '\0';
		buffer = '\0';
		while(file.ReadString(buffer))  
		{  
			responseBody = responseBody + buffer;  
		}
		//responseBody.Insert(-1, "\"");
		//responseBody.Insert(responseBody.GetLength(), "\"");

		//关闭文件
		file.Close();
		//删除文件
		DeleteFile("datafile.txt");

		Json::Value root;
		Json::Value arrayObj;
		Json::Value item;

		item["header"] = "";
		item["body"] = responseBody.GetBuffer(0);
		item["code"] = 200;
		arrayObj.append(item);

		root["params"] = "";
		root["responseData"] = arrayObj;
		root["swapInfo"] = swapInfo.GetBuffer(0);
		root["code"] = 1;

		CString rst = root.toStyledString().c_str();
		return root.toStyledString().c_str();
	}catch(CFileException* pe)
	{
		TRACE(_T("File could not be opened, cause = %d\n"),
			pe->m_cause);
		pe->Delete();

		//若同时extraParams也为空，则提示用户没有数据源
		if (extraParams.IsEmpty())
		{
			AfxMessageBox("there are no data source, please check it!");
			return "";
		}
		return extraParams;
	}
#endif

#if 1
	//从临时文件读取数据
	try
	{	//若文件不存在，则会抛出异常
		//CStdioFile file("datafile.txt", CFile::modeNoTruncate|CFile::modeRead);
		//CString responseBody,buffer;
		//responseBody = '\0';
		//buffer = '\0';
		//while(file.ReadString(buffer))  
		//{  
		//	responseBody = responseBody + buffer;  
		//}

		////关闭文件
		//file.Close();
		////删除文件
		//DeleteFile("datafile.txt");

		Json::Value root;
		Json::Value subRoot;
		Json::FastWriter writer;  

		subRoot["header"] = "";
		subRoot["body"] = responseBody.GetBuffer(0);
		subRoot["code"] = 200;

		root["params"] = "";
		root["responseData"] = subRoot;
		root["swapInfo"] = swapInfo;
		root["code"] = 1;

		//生成字符串格式的json
		std::string jsonStr = writer.write(root);

		//修改字符串，再其前后加一对[[]]
		//CString rst = jsonStr.c_str();
		//rst.Insert(-1, "[[");
		//rst.Insert(rst.GetLength(), "]]");
		return jsonStr.c_str();
	}catch(CFileException* pe)
	{
		TRACE(_T("File could not be opened, cause = %d\n"),
			pe->m_cause);
		pe->Delete();

		//若同时extraParams也为空，则提示用户没有数据源
		if (extraParams.IsEmpty())
		{
			AfxMessageBox("there are no data source, please check it!");
			return "";
		}
		return extraParams;
	}

#endif
}

bool handleHTTP()
{
	std::string url = headsInfo["url"].asString();
	std::string method = headsInfo["method"].asString();
	Json::Value header = headsInfo["header"];
	Json::Value params = headsInfo["params"];

	CHttpClient         objHttpReq ;
	CHttpResponse *     pobjHttpRes = NULL ;

	try {
		// Initialize the User Agent
		objHttpReq.SetInternet (_T("Mozilla/5.0 (iPhone; CPU iPhone OS 8_2 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12D508 (384115952)/Worklight/6.0.0")) ;

		// Specifies whether to use UTF-8 encoding. Default is FALSE
		// (This uses ANSI encoding)
		objHttpReq.SetUseUtf8 (FALSE) ;

		// Specifies a code page for ANSI strings. Default is CP_ACP
		objHttpReq.SetAnsiCodePage (CP_ACP) ;

		// Add user's custom HTTP headers
		for (Json::ValueIterator it = header.begin(); it != header.end(); it++)
		{
			Json::Value key = it.key();
			Json::Value value = (*it);

			//通过trim()清除无用字符
			//CString key_str = trim(key.toStyledString());
			//CString value_str = trim(value.toStyledString());
			CString key_str = key.asCString();
			CString value_str = value.asCString();
			if (key_str != "User-Agent"){
				objHttpReq.AddHeader (key_str, value_str) ;
			}
		}

		// Add user's parameters
		for (Json::ValueIterator it = params.begin(); it != params.end(); it++)
		{
			Json::Value key = it.key();
			Json::Value value = (*it);

			//通过trim()清除无用字符
			//CString key_str = trim(key.toStyledString());
			//CString value_str = trim(value.toStyledString());
			CString key_str = key.asCString();
			CString value_str = value.asCString();

			objHttpReq.AddParam (key_str, value_str) ;
		}

		if (method == "GET")
			pobjHttpRes = objHttpReq.RequestGet (url.c_str()) ;
		else if (method == "POST")
		{
			objHttpReq.BeginPost (url.c_str()); 
			const DWORD     cbProceed = 1024 ;  // 1K
			while(!(pobjHttpRes = objHttpReq.Proceed (cbProceed)));
		}
		else
		{
			AfxMessageBox("error method! please check it!");
			return false;
		}

		// Here start to handle the returned CHttpResponse object.
		// Reads the HTTP status code
		if ((pobjHttpRes->GetStatus () != 200)&&(pobjHttpRes->GetStatus () != 401))
		{
			AfxMessageBox("response status does not equals to 200, please check it!");
			AfxMessageBox(pobjHttpRes->GetStatusText ());
			return false;
		}

		// Reads HTTP headers using an array of header names
		static LPCTSTR      szHeaders[] = 
		{ _T ("Server"), _T ("Date"), _T ("X-Powered-By"), 
		_T ("Content-Length"), _T ("Set-Cookie")
		, _T ("Expires"), _T ("Cache-control"), 
		_T ("Connection"), _T ("Transfer-Encoding")
		, _T ("Content-Type") } ;

		LPCTSTR     szHeader ;
		for (size_t i = 0; i < sizeof (szHeaders) / sizeof (LPCTSTR); i++) 
			szHeader = pobjHttpRes->GetHeader (szHeaders[i]);

		// Checks whether the returned stream is a text
		BOOL        bIsText = FALSE ;
		CString		header_str;
		//if ( szHeader = pobjHttpRes->GetHeader (_T ("Content-Type")) )
		//	bIsText = (0 == ::_tcsncicmp (szHeader, _T ("text/"), 5)) ;
		if ( header_str = pobjHttpRes->GetHeader((_T("Content-Type"))) )
			if (header_str.Find("text/") || header_str.Find("/json"))
				bIsText = TRUE;


		// Reads the length of the stream
		DWORD       dwContSize ;
		// If the length is not specified
		if ( !pobjHttpRes->GetContentLength (dwContSize) )
			dwContSize = 0 ;

		const DWORD     cbBuff = 1024 * 10 ;
		BYTE            byBuff[cbBuff] ;
		DWORD           dwRead ;
		size_t          cbTotal = 0 ;

		// open file, and output the data stream into it;
		//CStdioFile file("datafile.txt", CFile::modeCreate|CFile::modeWrite);

		// Reads the data stream returned by the HTTP server.
		while ( dwRead = pobjHttpRes->ReadContent (byBuff, cbBuff - 1) ) {
			cbTotal += dwRead ;

			if ( bIsText ) {
				byBuff[dwRead] = '\0' ;
				try
				{
					responseBody = (reinterpret_cast<LPCSTR> (byBuff));
				}
				catch (CFileException* e)
				{
					AfxMessageBox("write string error");
				}
				//printf ("%s", reinterpret_cast<LPCSTR> (byBuff)) ;
			}
		}

		//file.Close();
		if ( !bIsText )
			AfxMessageBox (_T ("%u bytes skipped..\n"), cbTotal) ;
	} catch (httpclientexception & e) {
		// Place exception handling codes here.
	}
	delete pobjHttpRes ;
	pobjHttpRes = NULL ;
	
	return true;
}

void CluaTestToolDlg::OnBnClickedOk()
{
	// TODO: Add your control notification handler code here
	CDialogEx::OnOK();

	//获取控件返回值
	UpdateData();
	
	AfxMessageBox(m_Combo_Action_str);
	//若一个Action内不只一个ServerCmd，则通过ServerCmd控制其继续执行
	CString strBuffer(_T(""));
	CString serverCmdArry[16];
	int cmdCount = 0;
	while (AfxExtractSubString(strBuffer, m_Edit_ServerCmd_str.GetBuffer(0), cmdCount, _T(';')))
		serverCmdArry[cmdCount++] = (strBuffer);

	//第一次运行Lua脚本，执行Request部分
	lua2app = runLuaScript(m_Edit_ActionName_str, m_Edit_SourceType_str, m_Edit_Params_str, m_EditBrowse_SelectFile_str);

	while(cmdCount,cmdCount>0,cmdCount--)
	{	
		//MFC解析Lua返回Header信息，Json格式
		decodeJson(lua2app);

		//MFC发送HTTP请求并接收响应
		if (!handleHTTP()){
			AfxMessageBox("http request failed, please check it!");
			return;
		}

		//打包服务器返回值
		app2lua = encodeJson("");

		//再次运行Lua脚本，执行Response部分,并获取下一次的Request部分
		lua2app = runLuaScript(m_Edit_ActionName_str, m_Edit_SourceType_str, app2lua, m_EditBrowse_SelectFile_str);

	}

	//用完lua的时候，调用下面一句来关闭lua库：
	lua_close (lua);
	return;
}


//void CluaTestToolDlg::OnEnSetfocusEditServercmd()
//{
//	// TODO: Add your control notification handler code here
//	m_Edit_ServerCmd_str = "";
//	UpdateData(FALSE);
//}


//void CluaTestToolDlg::OnEnSetfocusEditActionname()
//{
//	// TODO: Add your control notification handler code here
//	m_Edit_ActionName_str = "";
//	UpdateData(FALSE);
//}


//void CluaTestToolDlg::OnEnSetfocusEditbrowseSelectfile()
//{
//	// TODO: Add your control notification handler code here
//	m_EditBrowse_SelectFile_str = "";
//	UpdateData(FALSE);
//}


//void CluaTestToolDlg::OnCbnSelchangeComboAction()
//{
//	// TODO: Add your control notification handler code here
//}
