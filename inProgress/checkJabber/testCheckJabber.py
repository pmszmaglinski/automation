#!/usr/bin/python
'''
Unit test for class JabberService
'''

import unittest
from checkJabber import JabberService

command='/usr/lib/nagios/plugins/check_jabber'
host='jabber.domain.com'
port='5222'
expect_string="\"<?xml version='1.0'?><stream:stream xmlns:stream='http://etherx.jabber.org/streams'\""

class TestUM(unittest.TestCase):

  def setUp(self):
    self.js = JabberService(command,host,port,expect_string)

  '''
  Test constructor variables
  '''
  def testConstructorCommand(self):
    self.assertEqual(self.js.command,command)
  def testConstructorHost(self):
    self.assertEqual(self.js.host,host)
  def testConstructorPort(self):
    self.assertEqual(self.js.port,port)
  def testConstructorExpected_string(self):
    self.assertEqual(self.js.expect_string,expect_string)


  '''
  Test check method
  '''
  def testCheckReturn0(self):
   'Return string is ok'
   self.assertEqual(self.js.check(),0)
   self.assertEqual(self.js.serviceStatus,True)

  def testCheckReturn1(self):
   'Unexpected response from server'
   self.js.expect_string="\"<?xml version='1.0'?><stream:stream xmlns:stream='http://etherx.jabber.org/streamsWRONG'\""
   self.assertEqual(self.js.check(),1)

  def testCheckReturn2(self):
   'Command sytax error'
   self.js.expect_string="<?xml version='1.0'?><stream:stream xmlns:stream='http://etherx.jabber.org/streams'"
   self.assertEqual(self.js.check(),2)
   self.assertEqual(self.js.serviceStatus,False)

  def testCheckWrongPort(self):
   'Port error'
   self.js.port='5225'
   self.assertEqual(self.js.check(),2)
   self.assertEqual(self.js.serviceStatus,False)

  def testCheckWrongHost(self):
   'Hostname error'
   self.js.host='abber.alatek.com.pl'
   self.assertEqual(self.js.check(),2)
   self.assertEqual(self.js.serviceStatus,False)

  '''
  Check restart method
  '''
  def testCheckRestart(self):
   #self.assertEqual(self.js.restart(),0)
   #self.assertEqual(self.js.isRestarted,True)
   pass




if __name__ == '__main__':
  unittest.main()
