#!/usr/bin/python

# Script checks VPN connection (ping) || restart ipsec on Cisco hardware (log it)

import subprocess, pexpect, smtplib, time

# Vars to SSH + PING
MACHINE_TO_PING_FROM = 'root@IP_ADDRESS'
MACHINE_TO_PING = ''

def vpnRestart():
        # Vars to restert VPN connection on ASA to AWS
        AWS_VPN_PEER_1=""
        AWS_VPN_PEER_2=""
        ASA_USER=""
        ASA_IP=""
        LOG_FILE="/var/log/asaVpnRestart.log"
        ASA_PASSWORD=''

        # Expecto Ipsec Restartus
        child = pexpect.spawn ('ssh -o StrictHostKeyChecking=no ' + ASA_USER + '@' + ASA_IP)
        child.logfile_read = open(LOG_FILE, "a")
        child.expect (ASA_USER + '@' + ASA_IP + '\'s password:')
        child.sendline(ASA_PASSWORD)
        child.expect ('.*>')
        child.sendline('enable 5')
        child.expect('Password: ')
        child.sendline(ASA_PASSWORD)
        child.expect('.*#')
        child.sendline('show clock')
        child.expect('.*#')
        child.sendline('clear ipsec sa peer ' + AWS_VPN_PEER_1)
        child.expect('.*#')
        child.sendline('clear ipsec sa peer ' + AWS_VPN_PEER_2)
        child.expect('.*#')
        child.sendline('exit')

def sendEmail():
        # Some vars
        me='sender@email.com'
        you='recipeint@email.com'
        curdate=time.strftime("%d/%m/%Y %H:%M:%S")

        # Mail headers
        msg = ("From: %s\r\nTo: %s\r\nSubject:VPN restart on Cisco ASA\r\n\r\n" % (me, you))
        msg = msg + "VPN to AWS VPC restartted at " + curdate + "\nCouln't ping " + MACHINE_TO_PING + " from "                                                                          + MACHINE_TO_PING_FROM

        # Send the message via our own SMTP server, but don't include the
        # envelope header.
        s = smtplib.SMTP('localhost')
        s.sendmail(me, [you], msg)
        s.quit()
        
        try:
        retcode = subprocess.check_call("ssh " +
                                   MACHINE_TO_PING_FROM +
                                   " ping " + " -c2 " +
                                   MACHINE_TO_PING,
                                   shell=True)

      except subprocess.CalledProcessError as e:
        if (e.returncode==255):
          print "Blad SSH: ", e.returncode
        elif (e.returncode==1 or e.returncode==2):
          print "Ping problem: ", e.returncode
          vpnRestart()
          sendEmail()
      else:
        print "Unknown problem: ", e.returncode
