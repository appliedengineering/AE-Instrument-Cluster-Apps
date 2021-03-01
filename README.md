# AE-Instrument-Cluster-Apps
Source code for Applied Engineering Instrument Cluster Apps

**PLEASE NOTE: THIS PROJECT IS NOW DEPRECATED.**
You can find the successor to this project [here](https://github.com/appliedengineering/iOS-Applied-Engineering-App) and [here](https://github.com/appliedengineering/Android-Applied-Engineering-App).

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

How to use msgpack-java (taken from [here](https://msgpack.org/) and [here](https://github.com/msgpack/msgpack-java)):
```java 
// Create serialize objects.
List<String> src = new ArrayList<String>();
src.add("msgpack");
src.add("kumofs");
src.add("viver");

MessagePack msgpack = new MessagePack();
// Serialize
byte[] raw = msgpack.write(src);

// Deserialize directly using a template
List<String> dst1 = msgpack.read(raw, Templates.tList(Templates.TString));
System.out.println(dst1.get(0));
System.out.println(dst1.get(1));
System.out.println(dst1.get(2));

// Or, Deserialze to Value then convert type.
Value dynamic = msgpack.read(raw);
List<String> dst2 = new Converter(dynamic)
    .read(Templates.tList(Templates.TString));
System.out.println(dst2.get(0));
System.out.println(dst2.get(1));
System.out.println(dst2.get(2));
```

# iOS
