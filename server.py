#!/usr/bin/env python3

import socketserver
import time
import sys
from threading import Lock

# Messages
#
# ADD THIS ONE
# > OK 1552600761
#
# GET THIS
# > OK 1552600761 ONE
#
# STATS
# > test_queue 100 0 100 1552737448
# > available 40 0 40 1552737463

class QueueManager:
    QUEUE_MUTEX=0
    QUEUE_ADDS=1
    QUEUE_GETS=2
    QUEUE_LAST_USED=3
    QUEUE_DATA=4

    def __init__(self):
        self.message_id = int(time.time())
        self.message_id_mutex = Lock()
        self.queues = {}

    def add(self, queue, message):
        self.message_id_mutex.acquire()
        this_message_id = self.message_id
        self.message_id += 1
        self.message_id_mutex.release()

        if queue not in self.queues:
            self.queues[queue] = [Lock(), 0, 0, 0, []]

        x = self.queues[queue]
        x[self.QUEUE_MUTEX].acquire()
        x[self.QUEUE_ADDS] += 1
        x[self.QUEUE_LAST_USED] = int(time.time())
        x[self.QUEUE_DATA].append([this_message_id, message])
        x[self.QUEUE_MUTEX].release()

        return "OK {}\n".format(this_message_id)

    def get(self, queue):
        if queue not in self.queues:
            return "ERROR QUEUE EMPTY\n"

        message = ""

        x = self.queues[queue]
        x[self.QUEUE_MUTEX].acquire()
        if len(x[self.QUEUE_DATA]) == 0:
            message = "ERROR QUEUE EMPTY\n"
        else:
            this_message_id, message = x[self.QUEUE_DATA].pop(0)
            message = "OK {} {}\n".format(this_message_id, message)
            x[self.QUEUE_GETS] += 1
            x[self.QUEUE_LAST_USED] = int(time.time())
        x[self.QUEUE_MUTEX].release()

        return message

    def stats(self):
        message = ""

        for queue in self.queues:
            x = self.queues[queue]
            message += "{} {} {} {} {}\n".format(queue, x[self.QUEUE_ADDS], x[self.QUEUE_GETS], len(x[self.QUEUE_DATA]), x[self.QUEUE_LAST_USED])

        return message

class MyTCPHandler(socketserver.StreamRequestHandler):

    def handle(self):
        data = str(self.rfile.readline().strip(), "utf-8")

        parts = data.split(' ', 2)

        message = ''

        if parts[0] == 'ADD':
            if len(parts) == 3:
                message = qm.add(parts[1], parts[2])
            else:
                message = "ERROR ADD COMMAND TAKES TWO ARGUMENTS\n"
        elif parts[0] == 'GET':
            if len(parts) == 2:
                message = qm.get(parts[1])
            else:
                message = "ERROR GET COMMAND TAKES ONE ARGUMENT\n"
        elif parts[0] == 'STATS':
            if len(parts) == 1:
                message = qm.stats()
            else:
                message = "ERROR STATS COMMAND TAKES NO ARGUMENT\n"
        else:
            message = "ERROR UNKNOWN COMMAND {}\n".format(parts[0])

        print("{} {}".format(parts[0], message), end='')
        self.wfile.write(message.encode())


HOST, PORT = "localhost", 2000

qm = QueueManager()

with socketserver.TCPServer((HOST, PORT), MyTCPHandler) as server:
    # Activate the server; this will keep running until you
    # interrupt the program with Ctrl-C
    server.serve_forever()
