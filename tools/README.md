# Tools

## `smallq`

```bash
$ smallq smallq.yml
```

Passed a server config file (see the main README.md) it will manage the queues and daemonise if required

## `qtop`

```bash
$ qtop smallq.yml
```

Passed a client config file (see the main README.md) it will list the active queues alone with some basic statistics. It will update every 5 seconds. The `TPS` is the number of adds and gets that took place since it's last report. `^C` to terminate

```
11:53:27  |       adds |       gets |       size |        TPS
----------+------------+------------+------------+-----------
available |         40 |         18 |         22 |       0.20
results   |    1044439 |    1043723 |        716 |    5665.27

11:53:32  |       adds |       gets |       size |        TPS
----------+------------+------------+------------+-----------
available |         40 |         18 |         22 |       0.00
results   |    1057444 |    1046035 |      11409 |    3061.73

11:53:37  |       adds |       gets |       size |        TPS
----------+------------+------------+------------+-----------
available |         40 |         18 |         22 |       0.00
results   |    1068639 |    1061861 |       6778 |    5380.85
```

## `qdrain`

```bash
$ qdrain smallq.yml <queue_name> [<forever>]
```

Passed a client config file (see the main README.md) and a `queue_name` it will drain the named queue and then quit. If given a `forever` parameter (`true`, `yes`, `y` or `1`) it will drain the queue and then sleep for 5 seconds before trying to drain the queue again. `^C` to terminate
