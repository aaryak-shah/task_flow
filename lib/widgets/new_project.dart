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

enum Pages { P1, P2 }

class _NewProjectState extends State<NewProject> {
  Pages _currentPage = Pages.P1;
  PaymentMode _selectedMode = PaymentMode.None;
  String _selectedCategory = '';
  DateTime? _tentativeDeadline;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _clientController = TextEditingController();

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

    var projects = Provider.of<Projects>(context);

    List<Widget> _pageWidgets = [
      Container(
        height: MediaQuery.of(context).size.height * 0.9,
        // height: 460,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          boxShadow: [
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
                  decoration: InputDecoration(
                    labelText: 'Title',
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Container(
                height: 20,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                child: Row(
                  children: <Widget>[
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
              SizedBox(
                height: 50,
              ),
              Container(
                height: 20,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                child: Row(
                  children: <Widget>[
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
                      value: PaymentMode.None,
                      groupValue: _selectedMode,
                      onChanged: (PaymentMode? mode) {
                        setState(() {
                          _selectedMode = mode ?? PaymentMode.None;
                        });
                      },
                    ),
                    title: Text('No, this is not a paid project'),
                  ),
                  ListTile(
                    leading: Radio(
                      value: PaymentMode.Fixed,
                      groupValue: _selectedMode,
                      onChanged: (PaymentMode? mode) {
                        setState(() {
                          _selectedMode = mode ?? PaymentMode.None;
                        });
                      },
                    ),
                    title:
                        Text('Yes, I am paid a fixed amount for this project'),
                  ),
                  ListTile(
                    leading: Radio(
                      value: PaymentMode.Rate,
                      groupValue: _selectedMode,
                      onChanged: (PaymentMode? mode) {
                        setState(() {
                          _selectedMode = mode ?? PaymentMode.None;
                        });
                      },
                    ),
                    title: Text('Yes, I am paid every hour for this project'),
                  ),
                ],
              ),
              Spacer(),
              Theme(
                data: Theme.of(context).copyWith(
                    textTheme: TextTheme(
                  overline:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                )),
                child: Builder(
                  builder: (context) => ElevatedButton(
                    child: Text('NEXT'),
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
                                      initialDate:
                                          DateTime.now().add(Duration(days: 1)),
                                      firstDate:
                                          DateTime.now().add(Duration(days: 1)),
                                      lastDate: DateTime.now()
                                          .add(Duration(days: 1000)),
                                      helpText: "ADD TENTATIVE DEADLINE",
                                      confirmText:
                                          _selectedMode == PaymentMode.None
                                              ? 'CREATE PROJECT'
                                              : 'CONTINUE')
                                  .then((_deadline) {
                                if (_deadline != null) {
                                  _tentativeDeadline = _deadline;
                                  if (_selectedMode != PaymentMode.None) {
                                    setState(() {
                                      _currentPage = Pages.P2;
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
          boxShadow: [
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
                      return "Enter a" +
                          (_selectedMode == PaymentMode.Fixed
                              ? 'n amount'
                              : ' rate');
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Payment ' +
                        (_selectedMode == PaymentMode.Fixed
                            ? 'Amount in ₹'
                            : 'Rate in ₹/hr'),
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
              SizedBox(
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
                  decoration: InputDecoration(
                    labelText: 'Client Name',
                  ),
                ),
              ),
              Spacer(),
              ElevatedButton(
                child: Text('CREATE PROJECT'),
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
