#!/bin/bash

set -e

useradd -m splunk
#groupadd splunk

export SPLUNK_HOME="/opt/splunkforwarder"
export splunkuserpassword="Splunk.5"
export FWDSERVERIP=""
export FWDSERVERPORT="9997"

pushd /tmp/scripts/splunk

# VERSION 8.2.0
splunkpackagefilename=splunkforwarder-8.2.0.tgz
splunkpackagedownload="wget -O $splunkpackagefilename https://download.splunk.com/products/universalforwarder/releases/8.2.0/linux/splunkforwarder-8.2.0-e053ef3c985f-Linux-x86_64.tgz"

# Installs wget
if [ ! -x /usr/bin/wget ] ; then                                                                          
    command -v wget >/dev/null 2>&1 || command  yum -y install wget
fi

# This section deals with $SPLUNK_HOME
# if it's found, try to stop splunkd, then
# rename + move the existing Splunk install

if [ -x $SPLUNK_HOME ] ; then
    echo "$SPLUNK_HOME found, renaming and moving to /tmp/";
     $SPLUNK_HOME/bin/splunk stop
     mv -v $SPLUNK_HOME /tmp/splunk_$(date +%d-%m-%Y_%H:%M:%S)
else
    echo "$SPLUNK_HOME not found, progressing with installation..."
fi

 mkdir $SPLUNK_HOME

# This section deals with $splunkpackagefilename
# if it's found, proceed with installation
# if it's not found, download it

if [ -a ./$splunkpackagefilename ] ; then
    echo "$splunkpackagefilename found, progressing with installation";
else
    echo "$splunkpackagefilename not found, downloading..."
    $splunkpackagedownload
fi


# Untar the package
tar -xzvC /opt -f $splunkpackagefilename

#chown -R splunk:splunk $SPLUNK_HOME #need to fixthis later

# Takes ownership of $SPLUNK_HOME to root
chown -vR root $SPLUNK_HOME

$SPLUNK_HOME/bin/splunk status --accept-license --answer-yes --no-prompt --seed-passwd $splunkuserpassword
$SPLUNK_HOME/bin/splunk add forward-server $FWDSERVERIP:$FWDSERVERPORT -auth admin:$splunkuserpassword
$SPLUNK_HOME/bin/splunk add monitor /var/log -auth admin:$splunkuserpassword
$SPLUNK_HOME/bin/splunk clone-prep-clear-config
