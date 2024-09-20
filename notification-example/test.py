#!/bin/python3

from plyer import notification


def show_toast(title, message):
    notification.notify(
        title="TEST",
        message="MESSAGE",
        app_name="APP",
        timeout=10,
        hints={"desktop-entry": "APP.desktop",
               "category": "message", "urgency": 1}
    )


if __name__ == '__main__':
    print('Test')
    show_toast('Test', 'Message')
