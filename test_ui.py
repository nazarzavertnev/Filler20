# Form implementation generated from reading ui file 'c:\Users\karina\Documents\Docs\Python\Filler20\test.ui'
#
# Created by: PyQt6 UI code generator 6.5.1
#
# WARNING: Any manual changes made to this file will be lost when pyuic6 is
# run again.  Do not edit this file unless you know what you are doing.


from PyQt6 import QtCore, QtGui, QtWidgets


class Ui_MainWindow(object):
    def setupUi(self, MainWindow):
        MainWindow.setObjectName("MainWindow")
        MainWindow.resize(447, 623)
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Policy.Fixed, QtWidgets.QSizePolicy.Policy.Fixed)
        sizePolicy.setHorizontalStretch(50)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(MainWindow.sizePolicy().hasHeightForWidth())
        MainWindow.setSizePolicy(sizePolicy)
        font = QtGui.QFont()
        font.setBold(False)
        font.setWeight(50)
        MainWindow.setFont(font)
        MainWindow.setContextMenuPolicy(QtCore.Qt.ContextMenuPolicy.NoContextMenu)
        icon = QtGui.QIcon()
        icon.addPixmap(QtGui.QPixmap("c:\\Users\\karina\\Documents\\Docs\\Python\\Filler20\\../../../../Pictures/blender.ico"), QtGui.QIcon.Mode.Normal, QtGui.QIcon.State.On)
        MainWindow.setWindowIcon(icon)
        MainWindow.setTabShape(QtWidgets.QTabWidget.TabShape.Rounded)
        self.centralwidget = QtWidgets.QWidget(parent=MainWindow)
        self.centralwidget.setObjectName("centralwidget")
        self.label_2 = QtWidgets.QLabel(parent=self.centralwidget)
        self.label_2.setGeometry(QtCore.QRect(0, 5, 451, 621))
        self.label_2.setText("")
        self.label_2.setPixmap(QtGui.QPixmap("c:\\Users\\karina\\Documents\\Docs\\Python\\Filler20\\rty.png"))
        self.label_2.setScaledContents(True)
        self.label_2.setObjectName("label_2")
        self.label_3 = QtWidgets.QLabel(parent=self.centralwidget)
        self.label_3.setGeometry(QtCore.QRect(40, 40, 331, 91))
        font = QtGui.QFont()
        font.setFamily("Calibri")
        font.setPointSize(18)
        font.setBold(True)
        font.setWeight(75)
        self.label_3.setFont(font)
        self.label_3.setObjectName("label_3")
        self.eschf = QtWidgets.QCommandLinkButton(parent=self.centralwidget)
        self.eschf.setEnabled(False)
        self.eschf.setGeometry(QtCore.QRect(30, 190, 301, 61))
        self.eschf.setObjectName("eschf")
        self.commandLinkButton_2 = QtWidgets.QCommandLinkButton(parent=self.centralwidget)
        self.commandLinkButton_2.setEnabled(False)
        self.commandLinkButton_2.setGeometry(QtCore.QRect(30, 250, 222, 48))
        self.commandLinkButton_2.setObjectName("commandLinkButton_2")
        self.dial = QtWidgets.QDial(parent=self.centralwidget)
        self.dial.setEnabled(False)
        self.dial.setGeometry(QtCore.QRect(330, 200, 31, 31))
        self.dial.setProperty("value", 50)
        self.dial.setSliderPosition(50)
        self.dial.setOrientation(QtCore.Qt.Orientation.Vertical)
        self.dial.setWrapping(True)
        self.dial.setNotchesVisible(False)
        self.dial.setObjectName("dial")
        self.eschf_status = QtWidgets.QLabel(parent=self.centralwidget)
        self.eschf_status.setGeometry(QtCore.QRect(64, 230, 301, 16))
        palette = QtGui.QPalette()
        brush = QtGui.QBrush(QtGui.QColor(148, 148, 148))
        brush.setStyle(QtCore.Qt.BrushStyle.SolidPattern)
        palette.setBrush(QtGui.QPalette.ColorGroup.Active, QtGui.QPalette.ColorRole.WindowText, brush)
        brush = QtGui.QBrush(QtGui.QColor(156, 156, 156))
        brush.setStyle(QtCore.Qt.BrushStyle.SolidPattern)
        palette.setBrush(QtGui.QPalette.ColorGroup.Active, QtGui.QPalette.ColorRole.Text, brush)
        brush = QtGui.QBrush(QtGui.QColor(148, 148, 148))
        brush.setStyle(QtCore.Qt.BrushStyle.SolidPattern)
        palette.setBrush(QtGui.QPalette.ColorGroup.Inactive, QtGui.QPalette.ColorRole.WindowText, brush)
        brush = QtGui.QBrush(QtGui.QColor(156, 156, 156))
        brush.setStyle(QtCore.Qt.BrushStyle.SolidPattern)
        palette.setBrush(QtGui.QPalette.ColorGroup.Inactive, QtGui.QPalette.ColorRole.Text, brush)
        brush = QtGui.QBrush(QtGui.QColor(120, 120, 120))
        brush.setStyle(QtCore.Qt.BrushStyle.SolidPattern)
        palette.setBrush(QtGui.QPalette.ColorGroup.Disabled, QtGui.QPalette.ColorRole.WindowText, brush)
        brush = QtGui.QBrush(QtGui.QColor(120, 120, 120))
        brush.setStyle(QtCore.Qt.BrushStyle.SolidPattern)
        palette.setBrush(QtGui.QPalette.ColorGroup.Disabled, QtGui.QPalette.ColorRole.Text, brush)
        self.eschf_status.setPalette(palette)
        font = QtGui.QFont()
        font.setFamily("Segoe UI")
        self.eschf_status.setFont(font)
        self.eschf_status.setObjectName("eschf_status")
        MainWindow.setCentralWidget(self.centralwidget)

        self.retranslateUi(MainWindow)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

    def retranslateUi(self, MainWindow):
        _translate = QtCore.QCoreApplication.translate
        MainWindow.setWindowTitle(_translate("MainWindow", "Filler"))
        self.label_3.setText(_translate("MainWindow", "Alpha 0.1"))
        self.eschf.setText(_translate("MainWindow", "Электронные счета фактуры"))
        self.commandLinkButton_2.setText(_translate("MainWindow", "Кассовые книги"))
        self.eschf_status.setText(_translate("MainWindow", "Загрузка кодов..."))