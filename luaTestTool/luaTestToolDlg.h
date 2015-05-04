
// luaTestToolDlg.h : header file
//

#pragma once
#include "afxeditbrowsectrl.h"
#include "afxwin.h"


// CluaTestToolDlg dialog
class CluaTestToolDlg : public CDialogEx
{
// Construction
public:
	CluaTestToolDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	enum { IDD = IDD_LUATESTTOOL_DIALOG };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support


// Implementation
protected:
	HICON m_hIcon;

	// Generated message map functions
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	DECLARE_MESSAGE_MAP()
public:
	CMFCEditBrowseCtrl m_EditBrowse_SelectFile;
	CEdit m_Edit_ActionName;
	afx_msg void OnBnClickedOk();
	CString m_Edit_ActionName_str;
	CString m_EditBrowse_SelectFile_str;
	CString m_Edit_SourceType_str;
	CString m_Edit_Params_str;
	CString m_Edit_ServerCmd_str;
	CString lua2app;
	CString app2lua;
//	afx_msg void OnEnSetfocusEditServercmd();
//	afx_msg void OnEnSetfocusEditActionname();
//	afx_msg void OnEnSetfocusEditbrowseSelectfile();
};