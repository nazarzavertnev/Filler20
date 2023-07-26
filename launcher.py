from PyQt5 import uic, QtGui, QtTest
from PyQt5.QtWidgets import QApplication
import os
import winsound
import json

def start_launcher():
    print(os.getcwd())
    Form, Window = uic.loadUiType("designs\launcher.ui")
    app = QApplication([])
    window = Window()
    form = Form()
    form.setupUi(window)
    window.setFixedSize(447, 623)
    QtTest.QTest.qWait(1500)
    window.show()

    winsound.PlaySound("sound\cient.wav", winsound.SND_FILENAME | winsound.SND_ASYNC)

    for i in range(5):
        for j in range(99):
            form.dial.setValue(j)
            QtTest.QTest.qWait(10)

    codes_file = open('launcher\eschf\codes.json', encoding="utf8")
    codes_text = codes_file.read()
    codes_file.close()
    codes = json.loads(codes_text)
    print(codes)

    form.dial.hide()

    form.label_3.setText("Добро пожаловать!")
    form.eschf.setEnabled(True)
    form.eschf_status.setText("Всё хорошо")

    def eschf_enter():
        winsound.PlaySound("sound\enter.wav", winsound.SND_ASYNC)

    form.eschf.clicked.connect(eschf_enter)

    app.exec()