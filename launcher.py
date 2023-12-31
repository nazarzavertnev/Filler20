from PyQt5 import uic, QtTest
from PyQt5.QtGui import QPixmap
from PyQt5.QtWidgets import QApplication
import os
#import winsound
from playsound import playsound
import json
import random
import asyncio
from eschf import *

async def anim_dial(dial):
    for i in range(5):
        for j in range(99):
            dial.setValue(j)
            QtTest.QTest.qWait(10)
            print("test")


def start_launcher():
    ######################  Настройка окна  ######################
    print(os.getcwd())
    Form, Window = uic.loadUiType("designs/launcher.ui")
    app = QApplication([])
    window = Window()
    form = Form()
    form.setupUi(window)
    window.setFixedSize(968, 623)
    QtTest.QTest.qWait(1500)

    dyna_file = open('youKnow/texts.json', encoding="utf8")
    dyna_text = dyna_file.read()
    dyna_file.close()
    dyna = json.loads(dyna_text)

    random.seed()
    randNumber = str(random.randrange(1, 4))
    dyna_image = QPixmap("youKnow/0" + randNumber + ".png")
    form.pictureDyna.setPixmap(dyna_image)

    background_image = QPixmap("pictures/rty.png")
    form.background.setPixmap(background_image)
    
    form.labelDyna.setText(dyna['0' + randNumber + '_label'])
    form.descDyna.setText(dyna['0' + randNumber + '_desc'])
    window.show()
    ######################  Настройка окна  ######################

    random.seed()
    
    playsound("sound/cient" + str(random.randrange(1, 4)) + ".wav", block=False)

    asyncio.run(anim_dial(form.eschf_load))
    

    codes_file = open('launcher/eschf/codes.json', encoding="utf8")
    codes_text = codes_file.read()
    codes_file.close()
    codes = json.loads(codes_text)
    print(codes)

    QtTest.QTest.qWait(1000)

    form.eschf_load.hide()

    form.status.setText("Добро пожаловать!")
    form.eschf.setEnabled(True)
    form.eschf_status.setText("Всё хорошо")

    def eschf_enter():
        playsound("sound/enter.wav", block=False)
        QtTest.QTest.qWait(1000)
        form.pages.setCurrentIndex(1)
        start_update_page(form)

    form.eschf.clicked.connect(eschf_enter)

    app.exec()
