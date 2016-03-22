#vagrant-fluentd

a fluentd broker that exports logs to ElasticSearch

## Usage

To use this vagrant setup, run the command below.
```
vagrant up --provider=virtualbox
```

## Install Ubuntu fluentd broker manually

Install [fluentd](http://docs.fluentd.org/articles/install-by-deb)

```bash
curl -L https://toolbelt.treasuredata.com/sh/install-ubuntu-trusty-td-agent2.sh | sh
```

Install ElasticSearch plugin
```bash
/usr/sbin/td-agent-gem install fluent-plugin-elasticsearch
```

Edit /etc/td-agent/td-agent.conf
```
####
## Source descriptions:
##

## built-in TCP input
## @see http://docs.fluentd.org/articles/in_forward
<source>
  type forward
</source>

# HTTP input
# POST http://localhost:8888/<tag>?json=<json>
# POST http://localhost:8888/td.myapp.login?json={"user"%3A"me"}
# @see http://docs.fluentd.org/articles/in_http
<source>
  type http
  port 8888
</source>

## nxlog input
<source>
  type tcp
  format none
  port 5140
  tag nxlog
</source>

####
## Output descriptions:
## match all tags and output to elastic and stdout
##
<match *.**>
  type copy
  <store>
    type elasticsearch
    host <IP of ELASTIC SEARCH SERVER>
    port 80
    path /elastic/
    include_tag_key true
    logstash_format true
    flush_interval 10s
  </store>
  <store>
    type stdout
  </store>
</match>
```

Restart the Service

``` bash
sudo /etc/init.d/td-agent restart
```

Tail the logs

``` bash
tail /var/log/td-agent/td-agent.log
```


## Windows Server Setup

If you want a Windows server to send logs to the fluentd broker then you can do this.

Install [nxlog](http://docs.fluentd.org/articles/windows)

Configure to listen to a file and export logs to a TCP endpoint
```
define ROOT C:\Program Files\nxlog
# define ROOT C:\Program Files (x86)\nxlog

Moduledir %ROOT%\modules
CacheDir %ROOT%\data
Pidfile %ROOT%\data\nxlog.pid
SpoolDir %ROOT%\data
LogFile %ROOT%\data\nxlog.log

# NXlog JSON extension activation (needed to forward messages to Logstash)
<Extension json>
  Module      xm_json
</Extension>

<Input in>
  Module      im_file
  File        'C:\Temp\nxlog_test.log' #Put the file to be tailed here.
  SavePos     TRUE
  InputType   LineBased
  Exec	      parse_json();
  Exec        $EventTime = parsedate($timestamp);
</Input>

<Output out>
  Module om_tcp
  Host   <IP of Fluentd Broker>
  Port   5140
</Output>

<Route r>
  Path in => out
</Route>

```

Send a test message
```
curl -X POST -d 'json={"json":"my message from Windows"}' http://<IP OF FLUENTD SERVER>:8888/debug.test
```

Start the service in the foreground to test it
```
nxlog.exe -f -c nxlog.conf
```

## References

http://docs.fluentd.org/articles/install-by-deb
http://docs.fluentd.org/articles/windows
