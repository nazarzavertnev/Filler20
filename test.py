from PyQt5 import uic
from PyQt5.QtWidgets import QApplication

import winsound

import time

import threading

from PyQt5 import QtTest

Form, Window = uic.loadUiType("test.ui")
Form2, Window2 = uic.loadUiType("test2.ui")

app = QApplication([])
window = Window()
form = Form()
form.setupUi(window)

window2 = Window2()
form2 = Form2()
form2.setupUi(window2)
winsound.PlaySound("sound\startap.wav", winsound.SND_ASYNC)

event = threading.Event()

window2.show()
while(form2.progressBar.value()!=100):
    form2.progressBar.setValue(form2.progressBar.value()+1)
    QtTest.QTest.qWait(30)

window2.close()
QtTest.QTest.qWait(1500)
window.show()

winsound.PlaySound("sound\startup.wav", winsound.SND_ASYNC)

def test():
    winsound.PlaySound("sound\qwerty4.wav", winsound.SND_ASYNC)
def test2():
    winsound.PlaySound("sound\qwerty5.wav", winsound.SND_ASYNC)

form.lineEdit.textChanged.connect(test)
form.lineEdit.returnPressed.connect(test2)

app.exec()
