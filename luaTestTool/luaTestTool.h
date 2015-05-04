
// luaTestTool.h : main header file for the PROJECT_NAME application
//

#pragma once

#ifndef __AFXWIN_H__
	#error "include 'stdafx.h' before including this file for PCH"
#endif

#include "resource.h"		// main symbols


// CluaTestToolApp:
// See luaTestTool.cpp for the implementation of this class
//

class CluaTestToolApp : public CWinApp
{
public:
	CluaTestToolApp();

// Overrides
public:
	virtual BOOL InitInstance();

// Implementation

	DECLARE_MESSAGE_MAP()
};

extern CluaTestToolApp theApp;