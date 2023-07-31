from PyQt5.QtGui import QStandardItemModel, QStandardItem
import os

def start_update_page (form):
    model = QStandardItemModel()
    folder = 'userFolder/vbs/in/'
    content = os.listdir(folder)
    for file in content:
        if os.path.isfile(os.path.join(folder, file)) and file.endswith('.txt'):
            model.appendRow(QStandardItem(file[0:len(file)-4]))
    form.fileView.setModel(model)