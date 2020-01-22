<?php
define("db_servername", "localhost");
define("db_username", "root");
define("db_password", "");
define("db_name", "eduprog");



function get_db_connection(){
    $conn = mysqli_connect(db_servername, db_username, db_password, db_name);
    return $conn;
}

function post_param($par){
	if (isset($_POST[$par])){
		return $_POST[$par];
	}

	return null;
}


//. main command
$_cmd = post_param("cmd");

//. TODO: check session dan login (jika pada aplikasi sebenarnya)

$response = array(
    "status" => -1,
    "desc" => "unknown error.",
    "cmd" => $_cmd,
	"data" => []
);

$conn = get_db_connection();

if ($_cmd == "get_all_data"){
	$_search = post_param("search");
	if (is_null($_search)) $_search  = "";
	if ($conn){
		$response["status"] = 1;
		$response["desc"] = "Success.";
		$response["data"] = get_all_data_siswa($conn, $_search);
	}else{
		$response["status"] = 0;
		$response["desc"] = "Database error.";
	}
}else if ($_cmd == "get_data_by_id"){
	$_id = post_param("id");
	if ($conn){
		$response["status"] = 1;
		$response["desc"] = "Success.";
		$response["data"] = get_data_siswa_by_id($conn, $_id);
	}else{
		$response["status"] = 0;
		$response["desc"] = "Database error.";
	}
}else if ($_cmd == "insert_data"){
	$_nama = post_param("nama");
	$_alamat = post_param("alamat");
	$_jk = post_param("jk");
	
	if ($conn){
		$b = insert_data_siswa($conn, $_nama, $_alamat, $_jk);
		if ($b){
			$response["status"] = 1;
			$response["desc"] = "Insert data success.";
		}else{
			$response["status"] = -2;
			$response["desc"] = "Insert data failed.";
		}
		
	}else{
		$response["status"] = 0;
		$response["desc"] = "Database error.";
	}
}else if ($_cmd == "delete_data_by_id"){
	$_id = post_param("id");
	$_id = mysqli_real_escape_string($conn, $_id);
	if ($conn){
		$b = delete_data_siswa_by_id($conn, $_id);
		if ($b){
			$response["status"] = 1;
			$response["desc"] = "Delete data success.";
		}else{
			$response["status"] = -2;
			$response["desc"] = "Delete data failed.";
		}
	}else{
		$response["status"] = 0;
		$response["desc"] = "Database error.";
	}
}else if ($_cmd == "update_data"){
	$_id = post_param("id");
	$_nama = post_param("nama");
	$_alamat = post_param("alamat");
	$_jk = post_param("jk");
	
	if ($conn){
		$b = update_data_siswa($conn, $_nama, $_alamat, $_jk, $_id);
		if ($b){
			$response["status"] = 1;
			$response["desc"] = "Update data success.";
		}else{
			$response["status"] = -2;
			$response["desc"] = "Update data failed.";
		}
		
	}else{
		$response["status"] = 0;
		$response["desc"] = "Database error.";
	}
}

header("Access-Control-Allow-Origin: *");

//. response
echo json_encode($response);


function get_all_data_siswa($conn, $search){
	$ret = [];
	
	$query = "select * from siswa";
	if ($search != ""){ //. jika ada query pencarian
		$search = mysqli_real_escape_string($conn, $search);
		$query .= " where nama like '%$search%' or alamat like '%$search%'";
	}
	if ($conn){
        $result = mysqli_query($conn, $query);
        if (mysqli_num_rows($result) > 0) {
            while($row = mysqli_fetch_assoc($result)) {
				array_push($ret, $row);
            }
        }
    }
	return $ret;
}

function get_data_siswa_by_id($conn, $id){
	$ret = [];
	$id = mysqli_real_escape_string($conn, $id);
	$query = "select * from siswa where id = '$id'";
	if ($conn){
        $result = mysqli_query($conn, $query);
        if (mysqli_num_rows($result) > 0) {
            while($row = mysqli_fetch_assoc($result)) {
				array_push($ret, $row);
                
            }
        }
    }
	
	return $ret;
}

function insert_data_siswa($conn, $_nama, $_alamat, $_jk){
	$ret = false;
	$_nama = mysqli_real_escape_string($conn, $_nama);
	$_alamat = mysqli_real_escape_string($conn, $_alamat);
	$_jk = mysqli_real_escape_string($conn, $_jk);
	$query = "insert into siswa(nama, alamat, jk) values ('$_nama','$_alamat','$_jk')";
	if ($conn){
        $ret = mysqli_query($conn, $query);
		//print( $result);
    }
	
	return $ret;
}

function update_data_siswa($conn, $_nama, $_alamat, $_jk, $_id){
	$ret = false;
	$_id = mysqli_real_escape_string($conn, $_id);
	$_nama = mysqli_real_escape_string($conn, $_nama);
	$_alamat = mysqli_real_escape_string($conn, $_alamat);
	$_jk = mysqli_real_escape_string($conn, $_jk);
	$query = "update siswa set nama = '$_nama', alamat = '$_alamat', jk = '$_jk' where id = '$_id'";
	if ($conn){
        $ret = mysqli_query($conn, $query);
		//print( $result);
    }
	
	return $ret;
}

function delete_data_siswa_by_id($conn, $id){
	$ret = false;
	$id = mysqli_real_escape_string($conn, $id);
	$query = "delete from siswa where id = '$id'";
	//print($query);
	if ($conn){
        $ret = mysqli_query($conn, $query);
		//print( $result);
    }
	
	return $ret;
}
?>