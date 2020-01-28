import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'utils.dart' as util;

class UploadFilePage extends StatefulWidget {
  UploadFilePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _UploadFilePageState createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {

  String _fileName;
  String _path;
  String _statusUpload = "Maksimal 3 file";
  Map<String, String> _paths;
  Map<String, String> _pathInWeb = {};
  String _extension;
  bool _loadingPath = false;
  bool _multiPick = false;
  bool _hasValidMime = false;
  FileType _pickingType;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _extension = _controller.text);
  }

  void _openFileExplorer() async {
    if (_pickingType != FileType.CUSTOM || _hasValidMime) {
      setState(() => _loadingPath = true);
      try {
        if (_multiPick) {
          _path = null;
          _paths = await FilePicker.getMultiFilePath(
              type: _pickingType, fileExtension: _extension);
        } else {
          _paths = null;
          _path = await FilePicker.getFilePath(
              type: _pickingType, fileExtension: _extension);
        }
      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return;
      setState(() {
        _loadingPath = false;
        _fileName = _path != null
            ? _path.split('/').last
            : _paths != null ? _paths.keys.toString() : '...';
      });
    }
  }

  Future<String> uploadFile(String contentBase64, String filename){
    Map<String, String> mRequest = {
      "_user": util.UserData.userName,
      "_session": util.UserData.userSession,//. dialokasikan
      "cmd": "upload_file",
      "filedata": contentBase64,
      "filename": filename
    };
    return util.httpPost(util.url_api, mRequest).then((data){
      var jObject = json.decode(data);
      if (jObject != null){
        String v_desc = jObject["desc"];
        String v_status = jObject["status"].toString();
        String v_data = jObject["data"].toString();
        String v_retVal = v_status + "#" + v_desc + "#" + v_data;
        return v_retVal;
      }else{
        return "";
      }


    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eduprog Upload File to Server'),
      ),
      body: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Text(_statusUpload, style: TextStyle(color: Colors.red),),
                    margin: EdgeInsets.only(bottom: 10),
                  ),
                  Container(
                    child: FlatButton(
                      child: Text("Start Upload To Server", style: TextStyle(color: Colors.white),),
                      onPressed: () async {
                        _pathInWeb.clear();
                        final bool isMultiPath = _paths != null && _paths.isNotEmpty;

                        if (isMultiPath){
                          List<String> lstPath = _paths.values.toList();
                          for (int i = 0; i < lstPath.length; i++){
                            final path = lstPath[i];
                            if (path != null && path.length > 0) {
                              final file = File(path);
                              List<int> contents = file.readAsBytesSync();
                              String base64File = base64Encode(contents);
                              String fileName = path.split("/").last;;
                              setState(() {
                                _statusUpload = "Uploading..";
                              });
                              uploadFile(base64File, fileName).then((result){
                                List<String> lstRet = result.split("#");
                                if (lstRet.length >= 2){
                                  if (lstRet[0] == "1") {
                                    //. kalau status = 1, artinya berhasil
                                    _pathInWeb[path] = lstRet[2];
                                    _statusUpload = "Upload success..";

                                  }else if (lstRet[0] == "-99"){ //. expired
                                    util.showAlert(context, lstRet[1], "Alert").then((d){
                                      Navigator.popUntil(context, ModalRoute.withName("/"));
                                    });
                                  }else{
                                    _pathInWeb[path] = lstRet[1];
                                  }
                                }

                                setState(() {

                                });
                              });
                            }else{
                              setState(() {
                                _statusUpload = "No file to upload..";
                              });
                            }
                          }
                        }else{
                          final path = _path;
                          if (path != null && path.length > 0) {
                            final file = File(path);
                            List<int> contents = file.readAsBytesSync();
                            String base64File = base64Encode(contents);
                            String fileName = path.split("/").last;;
                            setState(() {
                              _statusUpload = "Uploading..";
                            });
                            uploadFile(base64File, fileName).then((result){
                              List<String> lstRet = result.split("#");
                              if (lstRet.length >= 2){
                                if (lstRet[0] == "1") {
                                  //. kalau status = 1, artinya berhasil
                                  _pathInWeb[path] = lstRet[2];
                                  _statusUpload = "Upload success..";

                                }else if (lstRet[0] == "-99"){ //. expired
                                  util.showAlert(context, lstRet[1], "Alert").then((d){
                                    Navigator.popUntil(context, ModalRoute.withName("/"));
                                  });
                                }else{
                                  _pathInWeb[path] = lstRet[1];
                                }
                              }

                              setState(() {

                              });
                            });
                          }else{
                            setState(() {
                              _statusUpload = "No file to upload..";
                            });
                          }

                        }



                      },
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(6.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.8),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),

                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: DropdownButton(
                        hint: Text('LOAD PATH FROM'),
                        value: _pickingType,
                        items: <DropdownMenuItem>[
                          DropdownMenuItem(
                            child: Text('FROM AUDIO'),
                            value: FileType.AUDIO,
                          ),
                          DropdownMenuItem(
                            child: Text('FROM IMAGE'),
                            value: FileType.IMAGE,
                          ),
                          DropdownMenuItem(
                            child: Text('FROM VIDEO'),
                            value: FileType.VIDEO,
                          ),
                          DropdownMenuItem(
                            child: Text('FROM ANY'),
                            value: FileType.ANY,
                          ),
                          DropdownMenuItem(
                            child: Text('CUSTOM FORMAT'),
                            value: FileType.CUSTOM,
                          ),
                        ],
                        onChanged: (value) => setState(() {
                          _pickingType = value;
                          if (_pickingType != FileType.CUSTOM) {
                            _controller.text = _extension = '';
                          }
                        })),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(width: 100.0),
                    child: _pickingType == FileType.CUSTOM
                        ? TextFormField(
                      maxLength: 15,
                      autovalidate: true,
                      controller: _controller,
                      decoration:
                      InputDecoration(labelText: 'File extension'),
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.none,
                      validator: (value) {
                        RegExp reg = RegExp(r'[^a-zA-Z0-9]');
                        if (reg.hasMatch(value)) {
                          _hasValidMime = false;
                          return 'Invalid format';
                        }
                        _hasValidMime = true;
                        return null;
                      },
                    )
                        : Container(),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(width: 200.0),
                    child: SwitchListTile.adaptive(
                      title: Text('Pick multiple files',
                          textAlign: TextAlign.right),
                      onChanged: (bool value) =>
                          setState(() => _multiPick = value),
                      value: _multiPick,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                    child: RaisedButton(
                      onPressed: () => _openFileExplorer(),
                      child: Text("Pilih File"),
                    ),
                  ),
                  Builder(
                    builder: (BuildContext context) => _loadingPath
                        ? Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: const CircularProgressIndicator())
                        : _path != null || _paths != null
                        ? Container(
                      padding: const EdgeInsets.only(bottom: 30.0),
                      height: MediaQuery.of(context).size.height * 0.50,
                      child: Scrollbar(
                          child: ListView.separated(
                            itemCount: _paths != null && _paths.isNotEmpty
                                ? (_paths.length >= 3 ? 3 : _paths.length)
                                : 1,
                            itemBuilder: (BuildContext context, int index) {
                              final bool isMultiPath =
                                  _paths != null && _paths.isNotEmpty;
                              final String name = 'File $index: ' +
                                  (isMultiPath
                                      ? _paths.keys.toList()[index]
                                      : _fileName ?? '...');
                              final path = isMultiPath
                                  ? _paths.values.toList()[index].toString()
                                  : _path;
                              String http = "";
                              if (_pathInWeb != null && _pathInWeb.containsKey(path)){
                                http = _pathInWeb[path];
                              }

                              return ListTile(
                                title: Text(
                                  name,
                                ),
                                subtitle: Column(
                                  children: <Widget>[
                                    Text(path),
                                    Text(http, style: TextStyle(color: Colors.pink),),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                Divider(),
                          )),
                    )
                        : Container(),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}