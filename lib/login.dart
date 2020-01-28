import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'utils.dart' as util;

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {



  TextEditingController _txtUser = TextEditingController();
  TextEditingController _txtPassword = TextEditingController();
  //. flag loading
  bool _isLoading = false;
  bool _checkSession = true;
  int _defaultIndex = 0;
  @override
  Widget build(BuildContext context) {

    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: _checkSession == true ?
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(
              height: 20,
            ),
            Text("Checking Session..")
          ],
        ),
      )
      :
      SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Stack(
          children: <Widget>[
            ClipPath(
              child: Container(
                color: Colors.blue[400],
                height: 140,
                width: screenSize.width,
              ),
              clipper: WaveClipperOne(),
            ),
            ClipPath(
              child: Container(
                color: Colors.blue[600],
                height: 120,
                width: screenSize.width,
              ),
              clipper: WaveClipperTwo(),
            ),

            Positioned(
              child: ClipPath(
                child: Container(
                  color: Colors.blue[400],
                  height: 80,
                  width: screenSize.width,
                ),
                clipper: WaveClipperOne(reverse: true),
              ),
              bottom: 0,
              left: 0,
            ),
            Positioned(
              child: ClipPath(
                child: Container(
                  color: Colors.blue[600],
                  height: 90,
                  width: screenSize.width,
                ),
                clipper: WaveClipperTwo(reverse: true),
              ),
              bottom: 0,
              left: 0,
            ),

            SingleChildScrollView(
              child: Container(
                //for small
                width: screenSize.width,
                height: screenSize.height,
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 100),
                      height: 200,
                      child: _isLoading ?
                      Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(),
                          SizedBox(height: 10,),
                          Text("Loading...")
                        ],
                      ),) :
                      Image.asset("assets/eduprog.png", fit: BoxFit.contain,),
                    ),

                    SizedBox(height: 32,),
                    Container(
                      child: Text("Pilih Halaman"),
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      child: Wrap(
                        spacing: 10,
                        children: <Widget>[
                          ChoiceChip(
                            selected: _defaultIndex == 0 ? true : false,
                            label: Text("    CRUD    "), // your custom label widget
                            onSelected: (b){
                              setState(() {
                                _defaultIndex = 0;
                              });
                            },
                          ),
                          ChoiceChip(
                            selected: _defaultIndex == 1 ? true : false,
                            label: Text("Upload File"),
                            onSelected: (b){
                              setState(() {
                                _defaultIndex = 1;
                              });
                            },// your custom label widget
                          ),

                        ],
                      ),
                    ),
                    Container(
                      //height: 130,
                      width: 350,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),

                      ),

                      child: Column(
                        children: <Widget>[

                          TextField(
                            controller: _txtUser,
                            obscureText: false,
                            style: TextStyle( fontSize: 20.0),
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                hintText: "Username",
                                border:
                                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
                          ),

                          Divider(color: Colors.transparent,),

                          TextField(
                            controller: _txtPassword,
                            obscureText: true,
                            style: TextStyle( fontSize: 20.0),
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                hintText: "Password",
                                border:
                                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
                          ),

                        ],
                      ),
                    ),
                    //SizedBox(height: 16,),
                    Container(
                      width: 350,
                      height: 80,
                      padding: EdgeInsets.only(top: 20, bottom: 10),
                      child: RaisedButton(
                          color: Colors.blue[600],
                          child: Text("Login", style: TextStyle(color: Colors.white, fontSize: 16),),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                            });
                            //. request login
                            Map<String, String> mRequest = {
                              "cmd": "login",
                              "user": _txtUser.value.text,
                              "password": _txtPassword.value.text,

                            };
                            util.httpPost(util.url_api, mRequest).then((data){
                              Future.delayed(Duration(seconds: 1), (){
                                setState(() {
                                  _isLoading = false;
                                });
                                if (data != null){
                                  var mData = json.decode(data);
                                  if (mData != null){
                                    int vStatus = mData["status"];
                                    String vDesc = mData["desc"];
                                    var vData = mData["data"];

                                    if (vStatus == 1){
                                      //. save data
                                      util.UserData.userName = _txtUser.value.text;
                                      util.UserData.userFullName = vData["user_full_name"].toString();
                                      util.UserData.userSession = vData["user_session"].toString();
                                      //. save to shared pref (untuk autologin, jika session masih valid)
                                      util.setConfigUser(util.UserData.userName);
                                      util.setConfigSession(util.UserData.userSession);
                                      if (_defaultIndex  == 0)
                                        Navigator.pushNamed(context, "/crud");
                                      else
                                        Navigator.pushNamed(context, "/upload");
                                    }else{
                                      //. failed
                                      util.showAlert(context, vDesc, "Error");
                                    }

                                  }else{
                                    util.showAlert(context, "Parsing respond error", "Error");
                                  }

                                }else{
                                  util.showAlert(context, "Login respond error", "Error");
                                }
                              });

                            });setState(() {
                              _checkSession = false;
                            });
                            //Navigator.pushNamed(context, "/crud");

                          }
                      ),

                    ),

                    Text("User : admin, Pass : 123")

                  ],
                ),

              ),
            ),


          ],
        ),

      ),
    );
  }

  @override
  void initState() {
    util.getConfigSession().then((_cfgSession){
      util.getConfigUser().then((_cfgUser){
        if (_cfgSession != null && _cfgUser != null){ //. test for validation
          Map<String, String> mRequest = {
            "_user": _cfgUser,
            "_session": _cfgSession,//. dialokasikan
            "cmd": "check_session"
          };
          util.httpPost(util.url_api, mRequest).then((data){
            if (data != null){
              var mData = json.decode(data);
              if (mData != null){
                if (mData["status"].toString() == "1"){
                  setState(() {
                    _txtUser.text = "";
                    _txtPassword.text = "";
                    _checkSession = false;
                  });
                  util.UserData.userName = _cfgUser;
                  util.UserData.userSession = _cfgSession;
                  Navigator.pushNamed(context, "/crud");
                }else{
                  setState(() {
                    _checkSession = false;
                  });
                }
              }else{
                setState(() {
                  _checkSession = false;
                });
              }
            }else{
              setState(() {
                _checkSession = false;
              });
            }
          });
        }else{ //. sudah pasti tidak valid
          setState(() {
            _checkSession = false;
          });
        }
      });
    });



    super.initState();
  }
}
