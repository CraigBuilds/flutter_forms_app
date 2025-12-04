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

void main() {
  final entries = Entries();
  runApp(
    ValueListenableBuilder(
      valueListenable: entries.listenable,
      builder: (_,_,_) => MyApp(entries: entries) // Rebuild the whole of MyApp when entries change,
    )
  );
}

// --- MyApp is a pure representation of the app state (Entries) ---
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

// --- A ListView Showing Saved Form Data ---

ListView buildFormDataListView(List<FormData> formData) {
  return ListView.builder(
    itemCount: formData.length,
    itemBuilder: (ctx, index) {
      final data = formData[index];
      return buildListTile(data);
    },
  );
}

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

// --- The Form Dialog Implementation ---

Future<void> showSimpleFormDialog({required BuildContext ctx, required void Function(FormData) onSubmit}) {
  final formKey = GlobalKey<FormState>(); //so the form content can be saved from an action button
  final state = FormData(); //The form needs extra state because the text can be edited and the checkbox toggled, before it is submitted, and we need to be able to render that.

  return showDialog<void>(
    context: ctx,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Simple form'),
        content: buildFormContent(formKey, state),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              formKey.currentState!.save();
              onSubmit(state);
              Navigator.of(ctx).pop();
            },
            child: const Text('Submit'),
          ),
        ],
      );
    },
  );
}

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
      ],
    ),
  );
}

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
