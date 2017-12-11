#!/bin/bash
# trapchild

# Example of cleaning up child processes while recieving terminating signals
 
sleep 120 & 
pid="$!"
 
sleep 120 &
pid="$pid $!"
 
echo "my process pid is: $$"
echo "my child pid list is: $pid"                                                                                                                                                               
                                                                                                                                                                                                
trap 'echo I am going down, so killing off my processes..; kill $pid; exit' SIGHUP SIGINT SIGQUIT SIGTERM                                                                                       
                                                                                                                                                                                                
wait 
