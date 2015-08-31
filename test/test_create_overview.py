__author__ = 'pbelmann'

import nose.tools as nose
from scripts import create_overview

def test_determine_class():
    clazz = create_overview.determine_class("(Bla)CARB")
    nose.assert_equal(clazz,"A")
