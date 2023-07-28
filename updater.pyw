from PyQt5 import uic, QtGui, QtTest
from PyQt5.QtWidgets import QApplication
import winsound
import os
import subprocess
from launcher import *

Form, Window = uic.loadUiType(r'designs\updater.ui')
app = QApplication([])
window = Window()
form = Form()
form.setupUi(window)
winsound.PlaySound("sound\startap.wav", winsound.SND_ASYNC)

window.show()

form.status.setText("Инициализация...")
form.progressBar.setValue(15)
subprocess.Popen("git init", shell = True)
QtTest.QTest.qWait(1050)
form.progressBar.setValue(25)

form.status.setText("Получение обновлений...")
subprocess.Popen("git status", shell = True)
QtTest.QTest.qWait(1050)
form.progressBar.setValue(35)

form.status.setText("Восстановление файлов...")
subprocess.Popen("git reset --hard", shell = True)
QtTest.QTest.qWait(1050)

form.status.setText("Получение статуса...")
form.progressBar.setValue(50)
subprocess.Popen("git pull https://github.com/nazarzavertnev/Filler20.git", shell = True)
QtTest.QTest.qWait(1050)
form.progressBar.setValue(75)

form.status.setText("Обновление...")
QtTest.QTest.qWait(1050)
subprocess.Popen("git fetch https://github.com/nazarzavertnev/Filler20.git", shell = True)
form.progressBar.setValue(100)
QtTest.QTest.qWait(1050)

window.close()
start_launcher()
