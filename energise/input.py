from typing import List, Optional, Tuple

from dialog import Dialog


class Input:
    MenuItem = Tuple[str, Optional[callable]]

    def __init__(self):
        self.d = Dialog(dialog='dialog')
        self.d.set_background_title('Energise')

    def menu(self, title: str, items: List[MenuItem]) -> None:
        choices = []
        for tag, item in enumerate(items):
            choices.append((str(tag + 1), item[0]))
        res = self.d.menu(title, choices=choices)
        if res[0] == 'ok':
            item = items[int(res[1]) - 1]
            if item[1]:
                item[1]()

    def confirm(self, text: str, label_yes: str = 'Yes', label_no: str = 'No'):
        res = self.d.yesno(text, yes_label=label_yes, no_label=label_no)
        return res == 'ok'


input = Input()
