import os, shutil
from behave import *
import nose.tools as nt


def get_env_path(context, file_):
    return os.path.join(context.env.cwd, file_)

def get_data_file_path(file_):
    dir_ = os.path.dirname(os.path.abspath(__file__))
    return os.path.join(dir_, '..', 'data', file_)

@when(u'I run the command')
def step_impl(context):
    context.output = context.env.run(
            "bash -c '{}'".format(os.path.expandvars(context.text)),
            expect_error  = True,
            expect_stderr = True)

@given(u'I create the file "{file_}" with the contents')
def step_impl(context, file_):
    with open(get_env_path(context, file_), 'w') as f:
        f.write(context.text)

@then(u'the exit code should be {code}')
def step_impl(context, code):
    returned = context.output.returncode
    nt.assert_equal(returned, int(code),
            "Process should return exit code {} but was {}".format(code, returned))

@given(u'I copy the example data files')
def step_impl(context):
    for row in context.table.rows:
        shutil.copy(get_data_file_path(row['source']),
                get_env_path(context, row['dest']))\

@given(u'I copy the example data directories')
def step_impl(context):
    for row in context.table.rows:
        shutil.copytree(get_data_file_path(row['source']),
                get_env_path(context, row['dest']))

@given(u'I create the directory "{directory}"')
def step_impl(context, directory):
    os.makedirs(get_env_path(context, directory))
