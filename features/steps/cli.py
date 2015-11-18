import os, shutil
from behave import *
import nose.tools as nt

def get_stream(context, stream):
    nt.assert_in(stream, ['stderr', 'stdout'],
                 "Unknown output stream {}".format(stream))
    return getattr(context.output, stream)

def get_env_path(context, file_):
    return os.path.join(context.env.cwd, file_)

def get_data_file_path(file_):
    dir_ = os.path.dirname(os.path.abspath(__file__))
    return os.path.join(dir_, '..', 'data', file_)

def assert_not_empty(obj):
    nt.assert_true(len(obj) > 0)

def assert_file_exists(file_):
    nt.assert_true(os.path.isfile(file_),
                   "The file \"{}\" does not exist.".format(file_))

def assert_file_not_empty(file_):
    with open(file_, 'r') as f:
        assert_not_empty(f.read().strip())

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

@then(u'the following files should exist and not be empty')
def step_impl(context):
    for row in context.table.rows:
        file_ = get_env_path(context, row['file'])
        assert_file_exists(file_)
        assert_file_not_empty(file_)

@then(u'the file "{file_}" should contain {lines_} lines')
def step_impl(context, file_, lines_):
    file_ = get_env_path(context, file_)
    nt.assert_equals(sum(1 for line in open(file_)), int(lines_))

@then(u'the {stream} should contain')
def step_impl(context, stream):
    output = get_stream(context, stream)
    nt.assert_in(context.text, output)

@then(u'the {stream} should be empty')
def step_impl(context, stream):
    output = get_stream(context, stream)
    nt.assert_equal(output, "",
                    "The {} should be empty but contains:\n\n{}".format(stream, output))
