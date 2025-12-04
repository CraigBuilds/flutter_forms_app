import 'package:flutter/material.dart';

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
// --- The Form Dialog Implementation ---
//

// A dumb dialog that shows a simple form with a text field and a checkbox.
// It doesn't do any state management itself, it just calls onSubmit with the filled FormData when submitted.
// It needs to hold a FormData instance to store the form data while editing (before submission).
Future<void> showSimpleFormDialog({required BuildContext ctx, required void Function(FormData) onSubmit}) {
  final formKey = GlobalKey<FormState>(); //so the form content can be saved from an action button
  final state = FormData();

  return showDialog<void>(
    context: ctx,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Simple form'),
        content: buildFormContent(formKey, state),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: const Text('Submit'),
            onPressed: () {
              formKey.currentState!.save();
              onSubmit(state);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      );
    },
  );
}

// A dumb widget that just builds the form content given a FormData instance to store the data into
// TextFormField and CheckboxFormField are stateful widgets, so they know when to rebuild themselves. They do not need any external state management/reactivity.
Widget buildFormContent(GlobalKey<FormState> formKey, FormData state) {
  return Form(
    key: formKey,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          initialValue: "Foo",
          decoration: const InputDecoration(labelText: 'Text'),
          onSaved: (value) {
            state.textValue = value ?? '';
          },
        ),
        const SizedBox(height: 8),
        CheckboxFormField(
          initialValue: false,
          title: const Text('Check me'),
          onSaved: (value) {
            state.checkedValue = value ?? false;
          },
        ),
      ]
    ),
  );
}

// A specialized FormField for CheckboxListTile, similar to Flutter's built-in TextFormField
class CheckboxFormField extends FormField<bool> {
  CheckboxFormField({
    super.key,
    required Widget title,
    bool initialValue = false,
    super.onSaved,
    super.validator,
  }) : super(
    initialValue: initialValue,
    builder: (field) {
      return CheckboxListTile(
        value: field.value ?? false,
        title: title,
        onChanged: (checked) => field.didChange(checked ?? false),
      );
    },
  );
}