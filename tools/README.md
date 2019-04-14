# Tools

## `qtop`

```bash
$ qtop smallq.yml
```

Passed a client config file (see the main README.md) it will list the active queues alone with some basic statistics. It will update every 5 seconds. The `TPS` is the number of adds and gets that took place since it's last report. `^C` to terminate

```
10:53:32   |       adds |       gets |       size |        TPS
-----------+------------+------------+------------+-----------
test_queue |      10000 |          0 |      10000 |          -
```

## `qdrain`

```bash
$ qdrain smallq.yml <queue_name> [<forever>]
```

Passed a client config file (see the main README.md) and a `queue_name` it will drain the named queue and then quit. If given a `forever` parameter (`true`, `yes`, `y` or `1`) it will drain the queue and then sleep for 5 seconds before trying to drain the queue again. `^C` to terminate
