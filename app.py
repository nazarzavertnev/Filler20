from noname import *

import wx
import wx.xrc
# When this module is run (not imported) then create the app, the
# frame, show it, and start the event loop.
app = wx.App()
frm = intro(None)
frm.Show()
intro.m_infoCtrl2.ShowMessage(None, "test")

#app manager
#new line for test
app.MainLoop()


