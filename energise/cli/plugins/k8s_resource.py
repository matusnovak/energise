from __future__ import (absolute_import, division, print_function)

import json

import yaml

__metaclass__ = type

from ansible.plugins.action import ActionBase


class ActionModule(ActionBase):
    TRANSFERS_FILES = False
    _VALID_ARGS = frozenset(('append', 'definition',))

    def run(self, tmp=None, task_vars=None):
        if task_vars is None:
            task_vars = dict()

        result = super(ActionModule, self).run(tmp, task_vars)
        del tmp  # tmp no longer has any effect

        try:
            args = self._task.args
            document = []
            if 'append' in args:
                document = list(yaml.safe_load_all(args['append']))
                if isinstance(document, dict):
                    document = [document]

            document.append(yaml.safe_load(json.dumps(args['definition'])))

            dump = ''
            for doc in document:
                dump += yaml.safe_dump(doc, explicit_start=True, default_flow_style=False)

            result['yaml'] = dump
        except Exception as e:
            print(e)
            result['failed'] = True
            result['msg'] = str(e)
        return result
