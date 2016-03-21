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
<ROOT>
  <source>
    type tcp
    format none
    port 5140
    tag syslog
  </source>
  <source>
    type http
    port 8888
    bind 0.0.0.0
    body_size_limit 32m
    keepalive_timeout 10s
  </source>
  <match *.**>
    type copy
    <store>
      type elasticsearch
      host notsplunk-internal.glgresearch.com
      port 80
      path /elastic/
      include_tag_key true
      logstash_format true
      flush_interval 10s
    </store>
  </match>
</ROOT>
```

Restart the Service

``` bash
sudo /etc/init.d/td-agent restart
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

<Input in>
  Module im_file
  File 'C:\Temp\nxlog_test.log' #Put the file to be tailed here.
  SavePos TRUE
  InputType LineBased
</Input>

<Output out>
  Module om_tcp
  Host <IP OF Fluentd Server>
  Port 5140
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
