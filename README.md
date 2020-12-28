# AE-Instrument-Cluster-Apps
Source code for Applied Engineering Instrument Cluster Apps

# Android

How to use JeroMQ PUB/SUB (taken from [here](https://github.com/trevorbernard/jeromq-examples/blob/master/src/main/java/com/trevorbernard/PubSub.java)):
```java
import org.zeromq.ZMQ;

public class PubSub {
  public static void main(String[] args) throws Exception {
    ZMQ.Context ctx = ZMQ.context(1);
    
    ZMQ.Socket pub = ctx.socket(ZMQ.PUB);
    ZMQ.Socket sub = ctx.socket(ZMQ.SUB);
    sub.subscribe("".getBytes());
    
    pub.bind("tcp://*:12345");
    sub.connect("tcp://127.0.0.1:12345");
    
    // Eliminate slow subscriber problem
    Thread.sleep(100);
    pub.send("Hello, world!");
    System.out.println("SUB: " + sub.recvStr());
    
    sub.close();
    pub.close();
    ctx.close();
  }
}
```

# iOS
