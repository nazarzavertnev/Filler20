from PyQt5 import uic, QtGui, QtTest
from PyQt5.QtWidgets import QApplication
import winsound
import os
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
os.system("git init")
QtTest.QTest.qWait(1500)
form.progressBar.setValue(25)

form.status.setText("Получение обновлений...")
os.system("git status")
QtTest.QTest.qWait(1500)
form.progressBar.setValue(35)

form.status.setText("Восстановление файлов...")
os.system("git reset --hard")
QtTest.QTest.qWait(1500)

form.status.setText("Получение статуса...")
form.progressBar.setValue(50)
os.system("git pull https://github.com/nazarzavertnev/Filler20.git")
QtTest.QTest.qWait(1500)
form.progressBar.setValue(75)

form.status.setText("Обновление...")
QtTest.QTest.qWait(1500)
os.system("git fetch https://github.com/nazarzavertnev/Filler20.git")
form.progressBar.setValue(100)
QtTest.QTest.qWait(1500)

window.close()
start_launcher()
