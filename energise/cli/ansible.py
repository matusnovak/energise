import os.path
from argparse import Namespace as Args

from ansible import context
from ansible.cli import CLI
from ansible.executor.playbook_executor import PlaybookExecutor
from ansible.inventory.manager import InventoryManager
from ansible.module_utils.common.collections import ImmutableDict
from ansible.parsing.dataloader import DataLoader
from ansible.plugins.callback import CallbackBase
from ansible.vars.manager import VariableManager
from colorama import Fore

SUPPRESSED_MSGS = {'All items completed'}


class ResultsCollectorCallback(CallbackBase):
    """A sample callback plugin used for performing an action as results come in.

    If you want to collect all results into a single object for processing at
    the end of the execution, look into utilizing the ``json`` callback plugin
    or writing your own custom callback plugin.
    """

    def __init__(self, *args, **kwargs):
        super(ResultsCollectorCallback, self).__init__(*args, **kwargs)
        self.parents = []

    def collect_parents(self, result):
        current_parents = []
        parent = result._task._parent
        while parent is not None:
            if parent.name:
                current_parents.append(parent.name)
            parent = parent._parent
        return current_parents

    def print_parents(self, current_parents) -> str:
        indent = ''

        for idx, parent in enumerate(current_parents):
            if len(self.parents) > idx and self.parents[idx] == parent:
                indent += '    '
            else:
                if len(self.parents) == idx:
                    self.parents.append(current_parents)
                else:
                    self.parents[idx] = parent
                print(f'{indent}{parent} => ')
                indent += '  '

        return indent

    def print_result(self, result, failed, unreachable):
        # current_parents = self.collect_parents(result)
        # indent = self.print_parents(current_parents)
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


def ansible_runner(args: Args) -> int:
    # action_loader.add_directory(os.path.abspath(os.path.join(os.path.dirname(os.path.realpath(__file__)), 'plugins')))

    loader = DataLoader()

    context.CLIARGS = ImmutableDict(tags={}, listtags=False, listtasks=False, listhosts=False, syntax=False,
                                    connection='ssh',
                                    module_path=None, forks=100, remote_user=None, private_key_file=None,
                                    ssh_common_args=None, ssh_extra_args=None, sftp_extra_args=None,
                                    scp_extra_args=None, become=False,
                                    become_method='sudo', become_user=None, verbosity=True, check=False,
                                    start_at_task=None, timeout=600)

    playbook_dir = os.path.abspath(os.path.join(os.path.dirname(os.path.realpath(__file__)), '..', 'playbook'))

    inventory = InventoryManager(loader=loader, sources=[os.path.join(playbook_dir, 'hosts')])

    variable_manager = VariableManager(loader=loader, inventory=inventory, version_info=CLI.version_info(gitinfo=False))

    variable_manager.extra_vars['include_vars_path'] = args.config_path

    become_pass = os.getenv('BECOME_PASS', None)
    if args.ask_become_pass and become_pass is None:
        become_pass = input('sudo password: ')
    passwords = {
        'become_pass': become_pass,
    }

    pbex = PlaybookExecutor(playbooks=[os.path.join(playbook_dir, 'site.yml')],
                            inventory=inventory,
                            variable_manager=variable_manager,
                            loader=loader,
                            passwords=passwords)

    pbex._tqm._stdout_callback = ResultsCollectorCallback()

    return pbex.run()
