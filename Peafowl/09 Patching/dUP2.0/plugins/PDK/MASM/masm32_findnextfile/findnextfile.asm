;******************************************************************************
;* Example for dUP2 Plugin for MASM 32 Compiler                               *
;******************************************************************************


.586p
.mmx		
.model flat, stdcall
option casemap :none

;******************************************************************************
;* INCLUDES                                                                   *
;******************************************************************************
include				\masm32\include\windows.inc
include				\masm32\include\user32.inc
include				\masm32\include\kernel32.inc
include				\masm32\include\shell32.inc
include				\masm32\include\advapi32.inc
include				\masm32\include\gdi32.inc
include				\masm32\include\comctl32.inc
include				\masm32\include\comdlg32.inc
include				\masm32\include\msvcrt.inc
include				\masm32\include\masm32.inc
include    			\masm32\macros\ucmacros.asm	;Unicode Macros
include				\masm32\macros\macros.asm

includelib			\masm32\lib\user32.lib
includelib			\masm32\lib\kernel32.lib
includelib			\masm32\lib\shell32.lib
includelib			\masm32\lib\advapi32.lib
includelib			\masm32\lib\gdi32.lib
includelib			\masm32\lib\comctl32.lib
includelib			\masm32\lib\comdlg32.lib
includelib			\masm32\lib\msvcrt.lib
includelib			\masm32\lib\masm32.lib

include				\masm32\include\wsock32.inc
includelib			\masm32\lib\wsock32.lib
include				\masm32\include\wininet.inc
includelib			\masm32\lib\wininet.lib

include 			\masm32\include\ole32.inc
includelib 			\masm32\lib\ole32.lib
include 			\masm32\include\oleaut32.inc
includelib 			\masm32\lib\oleaut32.lib


include 			..\dup2.inc
includelib			..\dup2.lib

include				plugin_data_struct.inc



;******************************************************************************
;* Custom Functions                                                           *
;******************************************************************************
DialogPlugin			PROTO :DWORD,:DWORD,:DWORD,:DWORD
SavePluginData			PROTO
LoadPluginData			PROTO





;******************************************************************************
;* DATA & CONSTANTS                                                           *
;******************************************************************************
.const

;---Dialog Controls---
BTN_SAVE			equ 101
BTN_CANCEL			equ 102

DLG_ENV_VAR			equ 103
DLG_BASEFOLDER			equ 104
DLG_FILENAME			equ 105
CHK_SCAN_SUBFOLDER		equ 106

.data?
hinst				dd ?
hDialogPlugin			dd ?
hwnd_dup2main			dd ?
current_plugin_data		dd ?

hDROPDOWN_TYPE			dd ?


module_description		db 1024 dup (?)



.data
pinfo				PLUGIN_INFO <DUP2_PLUGIN_VERSION,"com.d2k2.findnextfile","[Find Next File]","findnextfile.d2p">





;******************************************************************************
;* CODE                                                                       *
;******************************************************************************
.code

DllEntry proc _hInstance:HINSTANCE, _reason:DWORD, _reserved:DWORD
	
	.if _reason == DLL_PROCESS_ATTACH
		m2m     hinst, _hInstance
	.endif
        
	return  TRUE
DllEntry endp



;////////////////////////////////////////////////////////////////////////
;/ DUP2_PluginInfo is called when the plugin is loaded.
;/
;/ The function returns a pointer to the PLUGIN_INFO strucure which
;/ contains some important information about the plugin
;////////////////////////////////////////////////////////////////////////
DUP2_PluginInfo proc

	return offset pinfo
DUP2_PluginInfo endp




;////////////////////////////////////////////////////////////////////////
;/ DUP2_EditPluginData is called when you want to edit the plugin data.
;/
;/ There is no rule how to use the plugin data memory. Its structure is
;/ completely definded by the author of the plugin.
;/ Default size of the plugin data memory is 1024 Byte.
;////////////////////////////////////////////////////////////////////////
DUP2_EditPluginData proc _plugin_data:DWORD

	fn GetDup2MainDialogHandle
	mov hwnd_dup2main,eax
	
	;---save pointer to plugin data---
	m2m current_plugin_data,_plugin_data
	
	
	fn DialogBoxParam,hinst,"DIALOG_PLUGIN",hwnd_dup2main,addr DialogPlugin,0
	
	ret
DUP2_EditPluginData endp




;////////////////////////////////////////////////////////////////////////
;/ DUP2_ModuleDescription is called when dup want show a description
;/ of the plugin data content. 
;/ The function returns a pointer to a string which contains the description
;////////////////////////////////////////////////////////////////////////
DUP2_ModuleDescription proc uses esi edi ebx _plugin_data:DWORD
	
	mov byte ptr [module_description],0
	
	mov esi,_plugin_data
	
	fn lstrlen,addr [esi].MY_PLUGIN_DATA_STRUCTURE.filename
	.if eax > 0
	
		fn lstrlen,addr [esi].MY_PLUGIN_DATA_STRUCTURE.filepath
		.if eax>0
			fn wsprintf,addr module_description,chr$("%s\%s  => %%%s%%"),addr [esi].MY_PLUGIN_DATA_STRUCTURE.filepath,addr [esi].MY_PLUGIN_DATA_STRUCTURE.filename,addr [esi].MY_PLUGIN_DATA_STRUCTURE.env_var
		.else
			fn wsprintf,addr module_description,chr$("%s => %%%s%%"),addr [esi].MY_PLUGIN_DATA_STRUCTURE.filename,addr [esi].MY_PLUGIN_DATA_STRUCTURE.env_var
		.endif		
	.endif
	
	mov eax,offset module_description
	ret
DUP2_ModuleDescription endp








;////////////////////////////////////////////////////////////////////////
;/ Custom Plugin Functions...
;////////////////////////////////////////////////////////////////////////

DialogPlugin proc uses ebx esi edi hwnd,message,wparam,lparam
	
	LOCAL local_buffer[1024]	:BYTE
	
	mov eax,message
	.if eax==WM_INITDIALOG
		
		;---save handle of plugin dialog---
		m2m hDialogPlugin,hwnd
		
		;---make dialog transparent or hide main dialog (depends on dup settings)---
		fn StartChooseHideMethod,hwnd
		
		;---load window position (use the unique id)---
      		invoke LoadWindowPosition,hwnd,addr pinfo.unique_plugin_id
      		

      		
      		;---tooltip---
      		fn AddToolTip,hwnd,DLG_BASEFOLDER,chr$("search in folder. examples:",13,10,"\subfolder",13,10,"%WINDIR%\system32")
      		fn AddToolTip,hwnd,DLG_FILENAME,chr$("file filter with wildcards. examples:",13,10,"*.*",13,10,"*.exe")
      		fn AddToolTip,hwnd,DLG_ENV_VAR,"Enter here the name of the environment variable where the filepath will be stored!"
	       
		
		;---load plugin data---
		fn LoadPluginData
		
	.elseif eax==WM_COMMAND
		
		mov eax,wparam
		.if 	ax==BTN_CANCEL
			fn SendMessage,hwnd,WM_CLOSE,0,0
			
		.elseif ax==BTN_SAVE
			
			;---save settings before close---
			
			mov bl,TRUE
			
			fn GetDlgItemText,hDialogPlugin,DLG_FILENAME,addr local_buffer,sizeof local_buffer
			.if eax==0
				fn MessageBox,hDialogPlugin,"Please enter a filefilter",0,MB_ICONEXCLAMATION
				jmp @no_save
			.endif
		
			fn GetDlgItemText,hDialogPlugin,DLG_ENV_VAR,addr local_buffer,sizeof local_buffer
			.if eax==0
				fn MessageBox,hDialogPlugin,"Please enter the name of the environment variable",0,MB_ICONEXCLAMATION
				jmp @no_save
			.endif
		

			fn SavePluginData
			fn SendMessage,hwnd,WM_CLOSE,0,0
			
			@no_save:
			
		.endif
	
	.elseif eax==WM_MOUSEMOVE
		;---move Dialog on clicking anywhere---
      		.if wparam==MK_LBUTTON	;left mouse button pressed?
			fn SendMessage,hwnd,WM_SYSCOMMAND,0F012h,0
		.endif
		
	.elseif eax==WM_CLOSE

		fn EndChooseHideMethod
		
		;---save window position (use the unique id)---
      		fn SaveWindowPosition,hwnd,addr pinfo.unique_plugin_id,POS_NOSIZE
		
		fn EndDialog,hwnd,0
		
	.else
		mov eax,FALSE
		ret
	.endif
	
	mov eax,TRUE
	ret
DialogPlugin endp


SavePluginData proc uses esi edi ebx
	
	;---resize plugin data memory, default size is 1024 byte---
	fn ResizeCurrentPluginDataMemory,sizeof MY_PLUGIN_DATA_STRUCTURE,FALSE
	mov current_plugin_data,eax
	
	mov esi,eax
	
	
	;---filepath---
	fn GetDlgItemText,hDialogPlugin,DLG_BASEFOLDER,addr [esi].MY_PLUGIN_DATA_STRUCTURE.filepath,1024
	
	;---filename---
	fn GetDlgItemText,hDialogPlugin,DLG_FILENAME,addr [esi].MY_PLUGIN_DATA_STRUCTURE.filename,1024
	
	;---environment variable name---
	fn GetDlgItemText,hDialogPlugin,DLG_ENV_VAR,addr [esi].MY_PLUGIN_DATA_STRUCTURE.env_var,512
	
	;---subfolder---
	fn IsDlgButtonChecked,hDialogPlugin,CHK_SCAN_SUBFOLDER
	.if eax==BST_CHECKED
		or [esi].MY_PLUGIN_DATA_STRUCTURE.options,FFF_SCAN_SUBFOLDER
	.endif
	
	
	ret
SavePluginData endp


LoadPluginData proc uses esi edi ebx
	
	mov esi,current_plugin_data
	
	
	;---filepath---
	fn SetDlgItemText,hDialogPlugin,DLG_BASEFOLDER,addr [esi].MY_PLUGIN_DATA_STRUCTURE.filepath
	
	;---filename---
	fn SetDlgItemText,hDialogPlugin,DLG_FILENAME,addr [esi].MY_PLUGIN_DATA_STRUCTURE.filename
	
	;---environment variable name---
	fn SetDlgItemText,hDialogPlugin,DLG_ENV_VAR,addr [esi].MY_PLUGIN_DATA_STRUCTURE.env_var

	
	;---subfolder---
	.if [esi].MY_PLUGIN_DATA_STRUCTURE.options & FFF_SCAN_SUBFOLDER
		fn CheckDlgButton,hDialogPlugin,CHK_SCAN_SUBFOLDER,BST_CHECKED
	.endif

	
	ret
LoadPluginData endp


end DllEntry
