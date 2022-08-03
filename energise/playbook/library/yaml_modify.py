#!/usr/bin/python

from __future__ import (absolute_import, division, print_function)

__metaclass__ = type

from typing import Union

import yaml
from ansible.module_utils.basic import AnsibleModule


def apply_op_list(document: list, op: str, value: str):
    if op == 'append':
        document.append(value)
    else:
        raise Exception(f'Unknown op type: {op}')


def apply_op_dict(document: dict, op: str, value: str):
    if op == 'update':
        document.update(value)
    else:
        raise Exception(f'Unknown op type: {op}')


def apply_op(document: Union[dict, list], op: str, value: str):
    if isinstance(document, dict):
        apply_op_dict(document, op, value)
    elif isinstance(document, list):
        apply_op_list(document, op, value)


def apply_action(document: Union[dict, list], op: str, key: str, value: str):
    if key == '':
        apply_op(document, op, value)
        return

    tokens = key.split('.')
    next = '.'.join(tokens[1:])

    if isinstance(document, dict):
        k = tokens[0]
        if k not in document:
            raise Exception(f'No such object key found: \'{k}\'')
        apply_action(document[k], op, next, value)

    elif isinstance(document, list):
        idx = int(tokens[0])
        if idx >= len(document) or idx < 0:
            raise Exception(f'No such list key found: {idx}')
        apply_action(document[idx], op, next, value)


def run_module():
    module_args = dict(
        yaml=dict(type='str', required=True),
        actions=dict(type='list', required=True),
    )

    result = dict(
        changed=False,
        yaml='',
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=False,
    )

    if module.check_mode:
        module.exit_json(**result)

    src = module.params['yaml']
    actions = module.params['actions']

    documents = list(yaml.safe_load_all(src))
    for document in documents:
        for action in actions:
            apply_action(document, action['op'], action['key'], action['value'])

    dump = ''
    for document in documents:
        dump += yaml.safe_dump(document, explicit_start=True, default_flow_style=False)

    result['yaml'] = dump

    module.exit_json(**result)

    """
    # manipulate or modify the state as needed (this is going to be the
    # part where your module will do what it needs to do)
    result['original_message'] = module.params['name']
    result['message'] = 'goodbye'

    # use whatever logic you need to determine whether or not this module
    # made any modifications to your target
    if module.params['new']:
        result['changed'] = True

    # during the execution of the module, if there is an exception or a
    # conditional state that effectively causes a failure, run
    # AnsibleModule.fail_json() to pass in the message and the result
    if module.params['name'] == 'fail me':
        module.fail_json(msg='You requested this to fail', **result)

    # in the event of a successful module execution, you will want to
    # simple AnsibleModule.exit_json(), passing the key/value results
    module.exit_json(**result)
    """


def main():
    run_module()


if __name__ == '__main__':
    main()
