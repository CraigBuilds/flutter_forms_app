import 'package:flutter/material.dart';

typedef RecordAB = ({int a, int b});
typedef RecordABFn = RecordAB Function(RecordAB);

void foo() {
  final RecordAB record = (a: 1, b: 2);
  debugPrint('Constructed Record = $record');
  final newRecord = printThenDoFn(copyWithIncrementedFields, record);
  debugPrint('After mutation, Record = $newRecord');
}

RecordAB copyWithIncrementedFields(RecordAB record) {
  return (a: record.a + 1, b: record.b + 1);
}

T printThenDoFn<T>(T Function(T) fn, T arg) {
  debugPrint('calling $fn with arg $arg');
  final result = fn(arg);
  debugPrint('fn returned $result');
  return result;
}

void main() {
  foo();
}