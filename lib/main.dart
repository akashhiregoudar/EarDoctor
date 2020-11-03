
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'addFilter.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite/tflite.dart';
import 'package:permission_handler/permission_handler.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  File file;
  double confidence;
  String entityId;
  String text;
  String name;
  String age;
  String gender;
  String earside;
  List<StorageInfo> storageInfo;
  List _output;



  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        file = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
    classifyImage(file);
  }

  Future captureImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        file = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }


  loadModel() async{
    await Tflite.loadModel(
        model: "assets/model.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
    );
  }

  classifyImage(File file) async {
    var output = await Tflite.runModelOnImage(
        path: file.path,
      imageMean: 0.0,
      imageStd: 350.0,
      numResults: 3,
      threshold: 0.75,
      asynch: true,
    );
    setState(() {
      _output = output;
    });
    print(_output);
  }

  void createFolder() async{
    List<StorageInfo> strInfo = await PathProviderEx.getStorageInfo();
    if(Directory(strInfo[0].rootDir+'/ear').existsSync()) {
      print('directory exists');
    } else {
      if(Permission.storage.status != PermissionStatus.granted) {
        await Permission.storage.request();
      }
      var res = Directory(strInfo[0].rootDir+'/ear').create();
      print(res);
    }
  }

  void getRootDirectory() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getInt('id') == null) {
      prefs.setInt('id', 1);
    }
  }


  @override
  void initState() {
    super.initState();
    getRootDirectory();
    loadModel();
    createFolder();
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top:8.0),
          child: Text('Ear Doctor',
          style: TextStyle(
              fontSize: 28,
            fontWeight: FontWeight.w600
          ),),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 30,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20,),
              Text(
                'Welcome',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 23
                ),
              ),
              Image.asset('assets/doc.png'),
              SizedBox(height: 10,),
              Text(
                'Enter Patient Details',
                style: TextStyle(
                  color: Colors.lightBlueAccent,
                  fontWeight: FontWeight.w400,
                  fontSize: 25
                ),
              ),
              SizedBox(height: 10,),
              SizedBox(height: 20,),
              TextFormField(
                style: TextStyle(
                  color: Colors.white
                ),
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.white
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(
                      color: Colors.white60,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.white60,
                      width: 2.0,
                    ),
                  ),
                    labelText: 'Enter Patient Name',
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 20,),
              TextFormField(
                keyboardType: TextInputType.number,
                style: TextStyle(
                    color: Colors.white
                ),
                onChanged: (value) {
                  setState(() {
                    age = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(
                      color: Colors.white60,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.white60,
                      width: 2.0,
                    ),
                  ),
                  labelText: 'Enter Patient Age',
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 20,),
              Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Colors.lightBlue
                ),
                child: DropdownButtonFormField(
                  style: TextStyle(
                      color: Colors.white
                  ),
                  hint: Text('Select Gender',style: TextStyle(color: Colors.white),),
                  elevation: 0,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.white
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(
                        color: Colors.white60,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Colors.white60,
                        width: 2.0,
                      ),
                    ),
                  ),
                  isExpanded: true,
                  items: <String>['Male','Female','Other'].map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(
                        value,
                      ),
                    );
                  }).toList(),
                  onChanged: (newval) {
                    setState(() {
                      gender = newval;
                    });
                  },
                ),
              ),
              SizedBox(height: 20,),
              Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Colors.lightBlue
                ),
                child: DropdownButtonFormField(
                  style: TextStyle(
                      color: Colors.white
                  ),
                  hint: Text('Select Ear Side',style: TextStyle(color: Colors.white),),
                  elevation: 0,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.white
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide(
                        color: Colors.white60,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Colors.white60,
                        width: 2.0,
                      ),
                    ),
                  ),
                  isExpanded: true,
                  items: <String>['Left','Right'].map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(
                        value,
                      ),
                    );
                  }).toList(),
                  onChanged: (newval) {
                    setState(() {
                      earside = newval;
                    });
                  },
                ),
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        side: BorderSide(
                          color: Colors.white,
                        )
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      color: Colors.blue,
                      onPressed: (){
                        getImage();
                      },
                      child: Text(
                        'Select Image',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                          side: BorderSide(
                            color: Colors.white,
                          )
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      color: Colors.blue,
                      onPressed: (){
                        captureImage();
                      },
                      child: Text(
                        'Capture Image',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                      side: BorderSide(
                        color: Colors.white,
                      )
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  color: Colors.blue,
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>AddFilter(file,[name,age,gender,earside], _output)));
                },
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

