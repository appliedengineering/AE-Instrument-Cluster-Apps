import time
import zmq

ctx = zmq.Context.instance()
radio = ctx.socket(zmq.RADIO)
dish = ctx.socket(zmq.DISH)
dish.rcvtimeo = 1000

dish.bind('udp://224.0.0.1:28650')
dish.join('telemetry')
radio.connect('udp://224.0.0.1:28650')

for i in range(10):
    time.sleep(0.1)
    radio.send(b'%03i' % i, group='telemetry')
    try:
        msg = dish.recv(copy=False)
    except zmq.Again:
        print('missed a message')
        continue
    print("Received %s:%s" % (msg.group, msg.bytes.decode('utf8')))

dish.close()
radio.close()
ctx.term()
