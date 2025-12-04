// This is a version of main.dart that uses flutter_form_builder instead of the built in `Form` and `FormField<T>` widgets.
// to run this version, type `flutter run -d windows -t lib/main2.dart` 
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class FormData {
  String textValue = '';
  bool checkedValue = false;
}

class Entries {
  final ValueNotifier<List<FormData>> items = ValueNotifier<List<FormData>>([]);
  void add(FormData data) {
    items.value = [...items.value, data];
  }
  List<FormData> get list => List.unmodifiable(items.value);
  ValueNotifier<List<FormData>> get listenable => items;
}

// Rebuild the whole of MyApp when entries change,
void main() {
  final entries = Entries();
  runApp(
    ValueListenableBuilder(
      valueListenable: entries.listenable,
      builder: (_,_,_) {
        debugPrint('Rebuilding MyApp with ${entries.list.length} entries');
        return MyApp(entries: entries);
      }
    )
  );
}

// 
//--- MyApp is a pure representation of the app state (Entries) ---
//

class MyApp extends StatelessWidget {
  final Entries entries;
  const MyApp({super.key, required this.entries});

  @override
  Widget build(BuildContext ctx) {
    return MaterialApp(
      title: 'Simple Form Dialog Demo',
      home: HomePage(entries: entries),
    );
  }
}

// A simple home page showing a list of saved form data (built from entries.list) and a button to add more (opens the form dialog)
class HomePage extends StatelessWidget {
  final Entries entries;
  const HomePage({super.key, required this.entries});

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      body: buildFormDataListView(entries.list),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showSimpleFormDialog(ctx: ctx, onSubmit: (formData) => entries.add(formData)),
      ),
    );
  }
}

//
// --- A ListView Showing Saved Form Data ---
//

// A dumb widget that just builds a ListView from a list of FormData
ListView buildFormDataListView(List<FormData> formData) {
  return ListView.builder(
    itemCount: formData.length,
    itemBuilder: (ctx, index) {
      final data = formData[index];
      return buildListTile(data);
    },
  );
}

// A dumb widget that just builds a ListTile from a FormData
ListTile buildListTile(FormData data) {
  return ListTile(
    title: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(data.textValue),
        const SizedBox(width: 8),
        Icon(
          data.checkedValue ? Icons.check_box : Icons.check_box_outline_blank,
        ),
      ],
    ),
  );
}

//
// --- The Form Dialog Implementation (this time using flutter_form_builder) ---
//


Future<void> showSimpleFormDialog({required BuildContext ctx, required void Function(FormData) onSubmit}) {
  return showDialog(
    context: ctx,
    builder: (ctx) => Placeholder()
  );
}