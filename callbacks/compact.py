from ansible.plugins.callback import CallbackBase
from colorama import Fore, Style

SUPPRESSED_MSGS = {'All items completed'}

class CallbackModule(CallbackBase):
    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'stdout'
    CALLBACK_NAME = 'compact'

    def __init__(self, *args, **kwargs):
        super(CallbackModule, self).__init__(*args, **kwargs)

    def print_result(self, result, failed, unreachable):
        indent = ''

        host = result._host
        role = result._task._role
        if role is not None:
            name = f'{role.get_name()} - {result.task_name}'
        else:
            name = f'{result.task_name}'

        if 'warnings' in result._result:
            for warning in result._result['warnings']:
                print(f'{Fore.YELLOW}Warning: {warning}{Fore.RESET}')
        if 'errors' in result._result:
            for warning in result._result['errors']:
                print(f'{Fore.RED}Error: {warning}{Fore.RESET}')
        if result.is_failed() or failed:
            print(f'{indent}{name}: {Fore.RED}Failed{Fore.RESET}')
        elif result.is_skipped():
            print(f'{indent}{name}: {Fore.CYAN}Skipped{Fore.RESET}')
        elif result.is_unreachable() or unreachable:
            print(f'{indent}{name}: {Fore.RED}Unreachable host: {host}{Fore.RESET}')
        elif result.is_changed():
            print(f'{indent}{name}: {Fore.GREEN}Changed{Fore.RESET}')
        else:
            print(f'{indent}{name}: {Fore.CYAN}Ok{Fore.RESET}')

        if failed:
            if 'module_stderr' in result._result:
                print(result._result['module_stderr'])
            else:
                print(result._result)

        if 'msg' in result._result:
            msg = result._result['msg']
            if msg not in SUPPRESSED_MSGS and len(msg) > 0:
                if result.is_failed() or failed:
                    print(f'{Fore.RED}{msg}{Fore.RESET}')
                else:
                    print(f'{Fore.CYAN}{msg}{Fore.RESET}')

    def v2_runner_on_unreachable(self, result):
        self.print_result(result, False, True)

    def v2_runner_on_ok(self, result, *args, **kwargs):
        self.print_result(result, False, False)

    def v2_runner_on_failed(self, result, *args, **kwargs):
        self.print_result(result, True, False)
