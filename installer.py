from pathlib import Path

from winshell import desktop

with open(Path(desktop()) / "Codeby.url", 'w', encoding='utf-8') as file:
    file.write('[InternetShortcut]\nURL=https://codeby.net/')