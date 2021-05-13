import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/models/project.dart';
import 'package:task_flow/providers/projects.dart';
import 'package:task_flow/screens/current_project_screen.dart';
import 'category_chip.dart';

class NewProject extends StatefulWidget {
  @override
  _NewProjectState createState() => _NewProjectState();
}

enum Pages { p1, p2 }

class _NewProjectState extends State<NewProject> {
  Pages _currentPage = Pages.p1;
  PaymentMode _selectedMode = PaymentMode.none;
  String _selectedCategory = '';
  late DateTime? _tentativeDeadline;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _clientController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isDisabled = true;
    Widget returnCatChips() {
      // function to return Category chips in the modal sheet
      setState(() {
        _selectedCategory.isNotEmpty ? isDisabled = false : isDisabled = true;
      });
      return CategoryChips(
        '',
        (selectedCategory) {
          setState(() {
            _selectedCategory = selectedCategory;
          });
        },
      );
    }

    final projects = Provider.of<Projects>(context);

    final List<Widget> _pageWidgets = [
      Container(
        height: MediaQuery.of(context).size.height * 0.9,
        // height: 460,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 100,
              spreadRadius: 100,
              offset: Offset(0, -100),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Theme(
                data: Theme.of(context)
                    .copyWith(primaryColor: Theme.of(context).accentColor),
                child: TextFormField(
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter a title";
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Container(
                height: 20,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                child: Row(
                  children: const <Widget>[
                    Text(
                      'Categories',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Center(
                  child: returnCatChips(),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Container(
                height: 20,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                child: Row(
                  children: const <Widget>[
                    Text(
                      'Is This A Paid Project?',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  ListTile(
                    leading: Radio(
                      value: PaymentMode.none,
                      groupValue: _selectedMode,
                      onChanged: (PaymentMode? mode) {
                        setState(() {
                          _selectedMode = mode ?? PaymentMode.none;
                        });
                      },
                    ),
                    title: const Text('No, this is not a paid project'),
                  ),
                  ListTile(
                    leading: Radio(
                      value: PaymentMode.fixed,
                      groupValue: _selectedMode,
                      onChanged: (PaymentMode? mode) {
                        setState(() {
                          _selectedMode = mode ?? PaymentMode.none;
                        });
                      },
                    ),
                    title: const Text(
                        'Yes, I am paid a fixed amount for this project'),
                  ),
                  ListTile(
                    leading: Radio(
                      value: PaymentMode.rate,
                      groupValue: _selectedMode,
                      onChanged: (PaymentMode? mode) {
                        setState(() {
                          _selectedMode = mode ?? PaymentMode.none;
                        });
                      },
                    ),
                    title: const Text(
                        'Yes, I am paid every hour for this project'),
                  ),
                ],
              ),
              const Spacer(),
              Theme(
                data: Theme.of(context).copyWith(
                  textTheme: const TextTheme(
                    overline:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                child: Builder(
                  builder: (context) => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).accentColor,
                      textStyle: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: (!isDisabled)
                        ? () async {
                            if (_formKey.currentState!.validate()) {
                              showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now()
                                          .add(const Duration(days: 1)),
                                      firstDate: DateTime.now()
                                          .add(const Duration(days: 1)),
                                      lastDate: DateTime.now()
                                          .add(const Duration(days: 1000)),
                                      helpText: "ADD TENTATIVE DEADLINE",
                                      confirmText:
                                          _selectedMode == PaymentMode.none
                                              ? 'CREATE PROJECT'
                                              : 'CONTINUE')
                                  .then((_deadline) {
                                if (_deadline != null) {
                                  _tentativeDeadline = _deadline;
                                  if (_selectedMode != PaymentMode.none) {
                                    setState(() {
                                      _currentPage = Pages.p2;
                                    });
                                  } else {
                                    projects
                                        .addProject(
                                          id: DateTime.now().toString(),
                                          name: _titleController.text,
                                          start: DateTime.now(),
                                          deadline: _tentativeDeadline!,
                                          category: _selectedCategory,
                                          paymentMode: _selectedMode,
                                          rate: 0.0,
                                          client: _clientController.text,
                                        )
                                        .then(
                                          (id) => Navigator.of(context)
                                              .pushReplacementNamed(
                                            CurrentProjectScreen.routeName,
                                            arguments: {
                                              'projectId': id,
                                              'index':
                                                  projects.projects.length - 1
                                            },
                                          ),
                                        );
                                  }
                                }
                              });
                            }
                          }
                        : null,
                    child: const Text('NEXT'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Container(
        height: MediaQuery.of(context).size.height * 0.75,
        // height: 460,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 100,
              spreadRadius: 100,
              offset: Offset(0, -100),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Theme(
                data: Theme.of(context)
                    .copyWith(primaryColor: Theme.of(context).accentColor),
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter a${_selectedMode == PaymentMode.fixed
                              ? 'n amount'
                              : ' rate'}";
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Payment ${_selectedMode == PaymentMode.fixed
                            ? 'Amount in ₹'
                            : 'Rate in ₹/hr'}',
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Theme(
                data: Theme.of(context)
                    .copyWith(primaryColor: Theme.of(context).accentColor),
                child: TextFormField(
                  controller: _clientController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter a client name";
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Client Name',
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).accentColor,
                  textStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                onPressed: (!isDisabled)
                    ? () async {
                        if (_formKey.currentState!.validate()) {
                          projects
                              .addProject(
                                id: DateTime.now().toString(),
                                name: _titleController.text,
                                start: DateTime.now(),
                                deadline: _tentativeDeadline!,
                                category: _selectedCategory,
                                paymentMode: _selectedMode,
                                rate: double.parse(_amountController.text),
                                client: _clientController.text,
                              )
                              .then(
                                (id) =>
                                    Navigator.of(context).pushReplacementNamed(
                                  CurrentProjectScreen.routeName,
                                  arguments: {
                                    'projectId': id,
                                    'index': projects.projects.length - 1
                                  },
                                ),
                              );
                        }
                      }
                    : null,
                child: const Text('CREATE PROJECT'),
              ),
            ],
          ),
        ),
      ),
    ];

    return Container(
      color: Theme.of(context).primaryColor,
      child: _pageWidgets[_currentPage.index],
    );
  }
}
