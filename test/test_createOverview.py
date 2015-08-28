__author__ = 'pbelmann'

import nose.tools as nose
from scripts import createOverview

def test_determine_class():
    clazz = createOverview.determine_class("(Bla)CARB")
    nose.assert_equal(clazz,"A")
