import 'dart:convert';

import 'package:flutter/material.dart';
import 'utils.dart' as util;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eduprog CRUD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Eduprog CRUD Demo'),
    );
  }
}

class DialogEditSiswa extends StatefulWidget {
  final String title;
  final Map rowSiswa;
  final String action; //. pembeda antara "edit" / "new"
  DialogEditSiswa({Key key, this.title, this.rowSiswa, this.action}) : super(key: key);

  @override
  _DialogEditSiswaState createState() => _DialogEditSiswaState();

}
class _DialogEditSiswaState extends State<DialogEditSiswa> {
  TextEditingController _txtID = TextEditingController();
  TextEditingController _txtNama = TextEditingController();
  TextEditingController _txtAlamat = TextEditingController();

  String _valSelectedJK = "L"; //. default value untuk dropdown

  bool isEdit(){
    return widget.action == "edit";
  }

  @override
  void initState() {
    // TODO: implement initState
    //_txtID.text = widget.rowSiswa["id"].toString();
    if (widget.action == "edit") { // jika edit, isi nilai control2 nya
      _txtNama.text = widget.rowSiswa["nama"].toString();
      _txtAlamat.text = widget.rowSiswa["alamat"].toString();
      _valSelectedJK = widget.rowSiswa["jk"].toString();
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AlertDialog(
      contentPadding: EdgeInsets.fromLTRB(2, 2, 2, 2),
      titlePadding: EdgeInsets.fromLTRB(10, 10, 5, 0),
      title: Text(widget.title),
      content: DefaultTextStyle(
        style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.8)),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.grey.withOpacity(0.2),
                  child: Row(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topRight,
                        width: 80,
                        child: Text("ID : "),
                      ),
                      SizedBox(width: 5,),

                      Expanded(
                        child: Container(
                          alignment: Alignment.topLeft,
                          child: Text(isEdit() ? widget.rowSiswa["id"].toString() : "#"),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.grey.withOpacity(0.3),
                  child: Row(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topRight,
                        width: 80,
                        child: Text("Nama : "),
                      ),
                      SizedBox(width: 5,),

                      Expanded(
                        child: Container(
                          alignment: Alignment.topLeft,
                          child: TextField(
                            decoration: InputDecoration(

                            ),
                            controller: _txtNama,
                            minLines: 1,
                            maxLines: 2,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.grey.withOpacity(0.2),
                  child: Row(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topRight,
                        width: 80,
                        child: Text("Alamat : "),
                      ),
                      SizedBox(width: 5,),
                      Expanded(
                        child: Container(
                          alignment: Alignment.topLeft,
                          child: TextField(
                            controller: _txtAlamat,
                            minLines: 2,
                            maxLines: 4,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.grey.withOpacity(0.3),
                  child: Row(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topRight,
                        width: 80,
                        child: Text("JK : "),
                      ),
                      SizedBox(width: 5,),
                      Expanded(
                        child: Container(
                          alignment: Alignment.topLeft,
                          child: DropdownButton(items: [
                            DropdownMenuItem(
                              value: "L",
                              child: Text("Laki-Laki"),
                            ),DropdownMenuItem(
                              value: "P",
                              child: Text("Perempuan"),
                            ),],
                          value: _valSelectedJK,
                          underline: Container(
                            height: 2,
                            color: Colors.grey,
                          ),
                          onChanged: (String newValue) {
                            setState(() {
                              _valSelectedJK = newValue;
                            });
                          },isDense: false,),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          color: Colors.green,
          child: Text('Save',),
          onPressed: (){
            String _id = isEdit() ? widget.rowSiswa["id"].toString() : "";
            String _nama = _txtNama.text;
            String _alamat = _txtAlamat.text;
            String _jk = _valSelectedJK;
            Map<String, String> mRequest = {
              "_user": "", //. dialokasikan
              "_session": "", //. dialokasikan
              "cmd": isEdit() ? "update_data" : "insert_data",
              "id": _id, //. ignored when *new* in server
              "nama": _nama,
              "alamat": _alamat,
              "jk": _jk,
            };
            util.showAlert(context, "Are you sure ?", isEdit() ? "Update Data, ID = ($_id)" : "Insert New Data").then((b){
              if (b == true){
                util.showLoading(context, true);
                util.httpPost(util.url_api, mRequest).then((data){
                  util.showLoading(context, false);
                  print(data);
                  var jObject = json.decode(data);
                  if (jObject != null){
                    String v_desc = jObject["desc"];
                    String v_status = jObject["status"].toString();
                    String v_retVal = v_status + "#" + v_desc;
                    //. return
                    Navigator.pop(context, v_retVal);
                    //_statusText = v_desc;
                  }


                });
              }
            });
          },
        ),
        FlatButton(
          color: Colors.redAccent,
          child: Text('Cancel'),
          onPressed: (){
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  bool _ready = false;
  List<dynamic> _lstDataSiswa = [];
  String _statusText = "";
  TextEditingController _txtSearch = TextEditingController();
  bool _flagAllowSearch = true;

  Future<bool> _loadData(String search) async{
    Map<String, String> mRequest = {
      "_user": "",
      "_session": "",
      "cmd": "get_all_data",
      "search": search
    };

    String data = await util.httpPost(util.url_api, mRequest);
    _ready = true;
    var jObject = json.decode(data);
    if (jObject != null){
      int v_status = jObject["status"];
      String v_desc = jObject["desc"];
      String v_cmd = jObject["cmd"];
      var v_data =  jObject["data"];
      if (v_status == 1){ //. success
        _lstDataSiswa = v_data;
      }else{
        _lstDataSiswa = [];
      }
    };

    return true;
  }

  void _showEditDialog(Map _row){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return DialogEditSiswa(rowSiswa: _row, title: "Edit Siswa", action: "edit");
        }
    ).then((ret){
      //. format kembalian (status#desc)
      if (ret != null && ret.toString().length > 0){
        List<String> lstRet = ret.toString().split("#");
        if (lstRet.length == 2){ //. harus dapat 2 length nya
          _statusText = lstRet[1];
          if (lstRet[0] == "1"){ //. kalau status = 1, artinya berhasil
            //. lanjut reload data
            util.showLoading(context, true);
            _loadData(_txtSearch.text).then((d){
              util.showLoading(context, false);
              //. refresh tampilan
              setState(() {

              });
            });
          }else{
            //. refresh tampilan
            setState(() {

            });
          }
        }
      }

    });

  }

  void _showNewDialog(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return DialogEditSiswa(rowSiswa: null, title: "Tambah Siswa", action: "new");
        }
    ).then((ret){
      //. format kembalian (status#desc)
      if (ret != null && ret.toString().length > 0){
        List<String> lstRet = ret.toString().split("#");
        if (lstRet.length == 2){ //. harus dapat 2 length nya
          _statusText = lstRet[1];
          if (lstRet[0] == "1"){ //. kalau status = 1, artinya berhasil
            //. lanjut reload data
            util.showLoading(context, true);
            _loadData(_txtSearch.text).then((d){
              util.showLoading(context, false);
              //. refresh tampilan
              setState(() {

              });
            });
          }else{
            //. refresh tampilan
            setState(() {

            });
          }
        }
      }

    });

  }

  @override
  void initState(){
    _loadData("").then((d){
      setState(() {

      });
    });
    super.initState();
  }

  List<Widget> _getRows(){
    List<Widget> lstRow = [];
    for (int i = 0 ; i < _lstDataSiswa.length; i++){
      dynamic _r = _lstDataSiswa[i];
      lstRow.add(Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.black.withOpacity(0.6), width: 2),
          ),
          color: (i % 2) == 0 ? Colors.white : Colors.black.withOpacity(0.1), //. odd event row
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              width: 50,
              child: Text(_r["id"].toString()),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(_r["nama"].toString()),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(_r["alamat"].toString()),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              width: 50,
              child: Text(_r["jk"].toString()),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              alignment: Alignment.center,
              width: 110,
              child: Row(
                children: <Widget>[
                  Material(
                    color: Colors.transparent,
                    child: Center(
                      child: Ink(
                        decoration: const ShapeDecoration(
                          color: Colors.green,
                          shape: CircleBorder(),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.edit),
                          color: Colors.white,
                          onPressed: () {
                            //util.showLoading(context, true);
                            _showEditDialog(_r);
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Material(
                    color: Colors.transparent,
                    child: Center(
                      child: Ink(
                        decoration: const ShapeDecoration(
                          color: Colors.red,
                          shape: CircleBorder(),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.delete),
                          color: Colors.white,
                          onPressed: () {
                            String _id = _r["id"].toString();
                            Map<String, String> mRequest = {
                              "_user": "",
                              "_session": "",
                              "cmd": "delete_data_by_id",
                              "id": _id
                            };
                            util.showAlert(context, "Are you sure ?", "Delete Data, ID = ($_id)").then((b){
                              if (b == true){
                                util.showLoading(context, true);
                                util.httpPost(util.url_api, mRequest).then((data){
                                  //print(data);
                                  var jObject = json.decode(data);
                                  if (jObject != null){
                                    String v_desc = jObject["desc"];
                                    _statusText = v_desc;
                                  }
                                  _loadData(_txtSearch.text).then((d){
                                    util.showLoading(context, false);
                                    setState(() {

                                    });
                                  });

                                });
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ));
    }
    
    if (_lstDataSiswa.length == 0){
      //. no data
      lstRow.add(Container(
        height: 400,
        child: Center(
          child: Text("Data Kosong", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.withOpacity(0.7)),),
        ),
      ));
    }

    return lstRow;
  }

  Widget _getTable(){
    return Column(
      children: <Widget>[
        Container(
          color: Colors.blue,
          child: DefaultTextStyle(
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            child: Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  width: 50,
                  child: Text("ID"),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Text("Nama"),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Text("Alamat"),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10),
                  width: 50,
                  child: Text("JK"),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10),
                  width: 110,
                  child: Text("Action"),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: _ready == true ? _getRows() :
              <Widget>[
                Container(
                  height: 400,
                    child: Center(child: CircularProgressIndicator(),))
              ],
            ),
          ),
        ),
        Container( //. alokasi buat footer
          height: 50,
          color: Colors.teal.withOpacity(0.6),
          child: Center(child: Text("Status : $_statusText", style: TextStyle(fontWeight: FontWeight.bold),),),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 50,
            child: Row(
              children: <Widget>[
                Container( //. biar seimbang
                  width: 100,
                ),
                Expanded(
                  child: Center(child: Text("Data Siswa", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),)),
                ),
                Container(
                  width: 100,
                  child: Row(
                    children: <Widget>[
                      IconButton(icon: Icon(Icons.refresh, color: Colors.grey,), onPressed: (){
                        util.showLoading(context, true);
                        _loadData(_txtSearch.text).then((data){
                          util.showLoading(context, false);
                          setState(() {

                          });
                        });
                      },),
                      IconButton(icon: Icon(Icons.add, color: Colors.orange,), onPressed: (){
                        _showNewDialog();
                      },),
                    ],
                  ),
                )

              ],
            ),
          ),
          Container(
            height: 50,
            child: TextField(
                controller: _txtSearch,
                onChanged: (filterText){
                  //. supaya efektif pencarianya, pakai timeout bukan per karakter
                  if (_flagAllowSearch == true){
                    _flagAllowSearch = false;

                    Future.delayed(Duration(milliseconds: 500), (){
                      _flagAllowSearch = true;
                      setState(() {
                        _ready = false;
                      });
                      _loadData(_txtSearch.text).then((d){
                        setState(() {
                          _ready = true;
                        });
                      });

                    });
                  }

                },
                style: TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                    prefixIcon: Icon(Icons.search),
                    prefixStyle: TextStyle(color: Colors.blue),
                    hintText: "Cari siswa..",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red.withOpacity(0.2), width: 32.0),
                        borderRadius: BorderRadius.circular(0.0)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red.withOpacity(0.2), width: 32.0),
                        borderRadius: BorderRadius.circular(0.0)))
            ),
          ),
          Expanded(child: _getTable())
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        tooltip: 'Tambah Siswa',
        child: Icon(Icons.add_box),
        backgroundColor: Colors.blueAccent,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
