#!/usr/bin/python

from __future__ import (absolute_import, division, print_function)

__metaclass__ = type

from typing import Union
import bcrypt
from ansible.module_utils.basic import AnsibleModule


def run_module():
    module_args = dict(
        user=dict(type='str', required=True),
        password=dict(type='str', required=True, no_log=True),
    )

    result = dict(
        changed=False,
        out='',
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=False,
    )

    if module.check_mode:
        module.exit_json(**result)

    user = module.params['user']
    password = module.params['password']

    password_hash = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt(rounds=12)).decode("utf-8")

    result['out'] = f'{user}:{password_hash}'

    module.exit_json(**result)


def main():
    run_module()


if __name__ == '__main__':
    main()
