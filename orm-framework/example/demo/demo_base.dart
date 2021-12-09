import 'dart:mirrors';

class DemoBase {
  void printInstance(Object instance, List<String> fieldsToPrint) {
    print("Instance: ${instance.runtimeType}");
    for (var item in fieldsToPrint) {
      InstanceMirror instanceMirror = reflect(instance);
      print("$item: ${instanceMirror.getField(Symbol(item)).reflectee}");
    }
  }

  void printInstanceList(List<Object> instances, List<String> fieldsToPrint) {
    int index = 0;
    for (var item in instances) {
      print("Element $index:");
      printInstance(item, fieldsToPrint);
      printSeperator();
      index++;
    }
  }

  void printSeperator() {
    print("------------------------------------------");
  }
}
