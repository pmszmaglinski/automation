#!/usr/bin/python

import subprocess, smtplib, time

class JabberService:
  """
  Class for checking, restarting and noticing when Jabber Service fail
  Uses nagios plugin
  """

  def __init__(self,command,host,port,expect_string):
    self.command = command
    self.host = host
    self.port = port
    self.expect_string = expect_string

    _tryCounter = 0
    isRestarted = False
    serviceStatus = None


  def check(self):
    '''
    Check if service is up & running
    '''
    try:
      retcode = subprocess.check_call(self.command + " -H " + self.host + " -p " + self.port + " -e " + self.expect_string,shell=True)
      self.serviceStatus = True
    except subprocess.CalledProcessError as e:
        if (e.returncode == 1):
          return e.returncode
        elif (e.returncode == 2):
          self.serviceStatus = False
          return e.returncode
        else:
          return e.returncode
    return retcode


  def restart(self):
    '''
    Restart Jabber service
    '''
    try:
      retcode = subprocess.check_call(["/etc/init.d/jabberd14 restart"],shell=True)
      self.isRestarted = True
    except subprocess.CalledProcessError as e:
          self.isRestarted = False
          return e.returncode
    return retcode

  def sendNotification():
    '''
    Send email notification
    '''
    pass


######## main() #########

def main():
  command='/usr/lib/nagios/plugins/check_jabber'
  host='jabber.domain.com'
  port='5222'
  expect_string="\"<?xml version='1.0'?><stream:stream xmlns:stream='http://etherx.jabber.org/streams'\""

  js = JabberService(command,host,port,expect_string)
 # print(js.check())
 # js.restart()


######### end main() ##########

if __name__ == '__main__':
  main()
