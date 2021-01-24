# Telemetry ZeroMQ Publisher
# Copyright (c) 2020 Applied Engineering

import concurrent.futures
import logging
import msgpack
import queue
import serial
import serial.tools.list_ports
import threading
import traceback
import zmq
import time

# Set logging verbosity.
# CRITICAL will not log anything.
# ERROR will only log exceptions.
# INFO will log more information.
log_level = logging.INFO

# ZeroMQ Context.
context = zmq.Context.instance()
# Define the socket using the Context.
radio = context.socket(zmq.RADIO)
radio.connect('udp://224.0.0.1:28650')

data = "Test"

while True:
    radio.send(str.encode(data), group='telemetry')
    print('sent')
    time.sleep(1)

radio.close()
context.term()
