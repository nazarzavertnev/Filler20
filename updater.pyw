from PyQt5 import uic, QtGui, QtTest
from PyQt5.QtWidgets import QApplication
import winsound
import os
from launcher import *

os.startfile("update.bat")

Form, Window = uic.loadUiType(r'designs\updater.ui')
app = QApplication([])
window = Window()
form = Form()
form.setupUi(window)
winsound.PlaySound("sound\startap.wav", winsound.SND_ASYNC)

window.show()
while(form.progressBar.value()!=100):
    form.progressBar.setValue(form.progressBar.value()+1)
    QtTest.QTest.qWait(30)
window.close()
start_launcher()