<?php
define("db_servername", "localhost");
define("db_username", "root");
define("db_password", "");
define("db_name", "eduprog");
define("base_url","http://nabita.info/eduprog/crud/");

//. session timeout in seconds
define("cfg_session_timeout", 60); // 60 detik (bisa diganti nantinya)


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


$response = array(
    "status" => -1,
    "desc" => "unknown error.",
    "cmd" => $_cmd,
	"data" => []
);

$conn = get_db_connection();

if ( $_cmd == "login"){
	$_user = post_param("user");
    $_passw = post_param("password");
	$row_login = [];
	// 0 = database error, 1 = success, 2 = user not registered, 3 = incorrect password, 4 = session failed
	$ret_login = do_login($_user, $_passw, get_db_connection(), $row_login);

	$response["status"] = $ret_login;

	if ($ret_login == 0){
		$response["desc"] = "Database error.";

	}else if ($ret_login == 1){
		$response["desc"] = "Success login.";
		$response["data"] = array(
			"user_full_name" => $row_login["user_full_name"],
			"user_session" => $row_login["user_session"]
		);
	}else if ($ret_login == 2){
		$response["desc"] = "User not registered.";
	}else if ($ret_login == 3){
		$response["desc"] = "Incorrect password.";
	}else if ($ret_login == 4){
		$response["desc"] = "Session failed.";
	}
}else if ( $_cmd == "logout"){
	$_user = post_param("_user");
    $_session = post_param("_session");

	// 0 = database error, 1 = success
	$ret_logout = do_logout($_user, $_session, get_db_connection());

	$response["status"] = $ret_logout;

	if ($ret_logout == 0){
		$response["desc"] = "Database error.";
	}else{
		$response["desc"] = "Success logout.";
	}

}else{
	//. bagian ini harus cek session terlebih dahulu
	$_user   = post_param("_user");
    $_session = post_param("_session");
	$bCheckSession = check_session($_user, $_session, get_db_connection());
	if ($bCheckSession == 0){
		$response["status"] = -99;
		$response["desc"] = "Session expired.";
	}else{
		if ($_cmd == "check_session"){ //. untuk cek session autologin
			$response["status"] = 1;
			$response["desc"] = "Success.";
		}else if ($_cmd == "upload_file"){
			$file_data   = post_param("filedata");
			$file_name   = post_param("filename");
			if (!empty($file_data)){
				$file_data = base64_decode($file_data);
				$this_dir = dirname(__FILE__);
				$file_path = '/upload/' . $file_name . "_" . substr(md5(uniqid()), 1,5) . ".file";
				$res = file_put_contents($this_dir . $file_path, $file_data); //. simpan ke folder upload, relative. tambahi random dan extensi .file
				if ($res){
					$file_url = base_url . substr($file_path, 1);
					$response["status"] = 1;
					$response["desc"] = "Upload success.";
					$response["data"] = $file_url;
				}else{
					$response["status"] = 0;
					$response["desc"] = "Upload file failed.";
				}
			}else{
				$response["status"] = 0;
				$response["desc"] = "Upload file failed.";
			}

		}else if ($_cmd == "get_all_data"){
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

//. 0 = database error, 1 = success, 2 = user not registered, 3 = incorrect password
function check_login($user_name, $user_password, $conn, &$row){
    $ret = 0;
    $user_name = mysqli_real_escape_string ($conn, $user_name);
    $user_password = md5($user_password);
    $query = "select * from users where user_name = '$user_name'";

    if ($conn){
        $result = mysqli_query($conn, $query);
        if (mysqli_num_rows($result) > 0) {
            while($row = mysqli_fetch_assoc($result)) {
                if ($row['user_password'] == $user_password){
                    $ret = 1;
                }else{
                    $ret = 3;
                }
                break;
            }
        }else{
            $ret = 2;
        }
    }else{
        $ret = 0;
    }

    return $ret;
}

//. 0 = invalid, 1 = valid
function check_session($user_name, $user_session, $conn){
    $ret = 0;
    $user_name = mysqli_real_escape_string ($conn, $user_name);
    $user_session = mysqli_real_escape_string ($conn, $user_session);
    $query = "select * from users where user_name = '$user_name' and user_session = '$user_session' and TIMESTAMPDIFF(SECOND,last_request, now()) <= " . cfg_session_timeout;

    if ($conn){
        $result = mysqli_query($conn, $query);
        if (mysqli_num_rows($result) > 0) {
			// update last_request
			$update = "update users set last_request = now() where user_name = '$user_name' and user_session = '$user_session'";
			$result = mysqli_query($conn, $update);
            $ret = 1;
        }else{
            $ret = 0;
        }
    }else{
        $ret = 0;
    }

    return $ret;
}

//. 0 = database error, 1 = success, 2 = user not registered, 3 = incorrect password , 4 = session failed
function do_login($user_name, $user_password, $conn, &$row){
	$b = check_login($user_name, $user_password, $conn, $row);
	if ($b ==  1){ //. update session
		//. generate session
		$session = md5("epsession" . uniqid());

		$query_update = "update users set user_session = '$session', last_request = now() where user_name = '$user_name'";
		$ret = mysqli_query($conn, $query_update);
		if ($ret){
			$row["user_session"] = $session;
		}else{
			$b = 4;
		}

	}
	return $b;

}

//. 0 = database error, 1 = success
function do_logout($user_name, $user_session, $conn){

	if ($conn){ //. update session
		$query_update = "update users set user_session = '', last_request = now() where user_session = '$user_session' and user_name = '$user_name'";
		$ret = mysqli_query($conn, $query_update);
		if ($ret){
			return 1;
		}else{
			return 0;
		}

	}else{

	}
	return 0;

}
?>