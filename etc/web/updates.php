<?

$s = @trim($_REQUEST['app_type']);
if($s!="" && $s!="MDO") { header("HTTP/1.0 400 Wrond application"); echo "Wrong app_type.\n"; exit; }

require("con_mysql.php");
include('class.phpmailer.php');

$f=@fopen("./log.txt", "w");
if($f) { @fwrite($f, print_r($_POST,1)); fclose($f); }


$layer_name=addslashes($layer_name);

if ($action=="packet_add") {

  $ID=(int)$ID;
  $filename=addslashes($filename);
  $date=time();
  if (isset($is_final) && $is_final) $is_final='Y';
    else $is_final='';

  if (!($filename=trim($filename)) || !$ID || !($layer_name=trim($layer_name))) {
    echo 'ERROR Incorrect input data.';
    exit();
  }

  $filename=ereg_replace('[.][.]/?|[.]/','',$filename);
  $out=exec('openssl dgst -md5 /web2/base_layers/htdocs/updates/'.$filename);

  if (!is_file('/web2/base_layers/htdocs/updates/'.$filename)) {
    echo 'ERROR File not found.<br>';
    echo '/web2/base_layers/htdocs/updates/'.$filename;
    exit();
  }
  if (!ereg('[a-f0-9]{32}',$out,$md5_file)) {
    echo 'ERROR Incorrect MD5 in script.';
    exit();
  }
  if ($md5!=$md5_file[0]) {
    echo 'ERROR Incorrect MD5 hash.';
    exit();
  }
  if (ereg('[.]php',$filename)) {
    echo 'ERROR Incorrect file.';
    exit();
  }

  $r=mysql_query("SELECT ID FROM layers WHERE name='$layer_name'");
  if ($f=mysql_fetch_array($r)) {
    $layerID=$f['ID'];
  } else {
    mysql_query("INSERT INTO layers SET name='$layer_name'");
    $layerID=mysql_insert_id();
  }
  
  mysql_query("INSERT INTO paket SET ID=$ID,layerID=$layerID,layer_name='$layer_name',filename='$filename',md5_hash='$md5',is_final='$is_final',date_add=$date");

  if (!mysql_errno()) echo "OK";
    else echo "ERROR ".mysql_error();

}

if ($action=="client_info") {

    // ИД клиента при поступлении
  if (isset($install_iid))
  {
    $install_iid=ereg_replace('"\'','',$install_iid);
  }

    // Узнаём ИД клиента (есть ли в базе)
     $r=mysql_query("SELECT ID FROM fz_clients WHERE uid='$install_iid'");
     //echo mysql_error();
     if (($f=mysql_fetch_array($r)) && $f['ID']) {
      $clientID=$f['ID'];
    } else {
      mysql_query("INSERT INTO fz_clients SET uid='$install_iid'");
      //echo mysql_error();
      $clientID=mysql_insert_id();
    }

    // Запись в таблицу fz_clients

  $set="";
  $last_IP=$_SERVER['REMOTE_ADDR'];
  if ($last_IP=="77.222.128.58") $is_local=1;
  else $is_local=0;
$set.="is_local=$is_local, LAST_IP='$last_IP'";
  //mysql_query("UPDATE fz_clients SET is_local=$is_local WHERE ID=$clientID");
  //mysql_query("UPDATE fz_clients SET LAST_IP='$last_IP' WHERE ID=$clientID");

      if (isset($install_client_name))
  {
    $install_client_name=trim($install_client_name);
    $set.=" ,install_client_name='$install_client_name'";
    //mysql_query("UPDATE fz_clients SET install_client_name='$install_client_name' WHERE ID=$clientID");
  }

    if (isset($client_okpo))
  {
    $client_okpo=trim($client_okpo);
    $client_okpo=substr($client_okpo,0,19);
    $set.=" ,OKPO='$client_okpo'";
    //mysql_query("UPDATE fz_clients SET OKPO='$client_okpo' WHERE ID=$clientID");
  }

    if (isset($client_hardkey))
  {
    $client_hardkey=$client_hardkey;
    $set.=" ,HARD_KEY='$client_hardkey'";    
    //mysql_query("UPDATE fz_clients SET HARD_KEY='$client_hardkey' WHERE ID=$clientID");
  }

mysql_query("UPDATE fz_clients SET $set WHERE ID=$clientID");
$f=@fopen("./log.txt", "w");
if($f) { @fwrite($f, $set); fclose($f); }
   
    
    // Запись в таблицу fz_log

    $set2="ID_CLIENT=$clientID";
        
        if (isset($client_version))
  {
    $set2.=" ,APP_VERSION='$client_version'";    
  }
          if (isset($client_db_version))
  {
    $set2.=" ,DB_VERSION=$client_db_version";    
  }
          if (isset($last_paket_id))
  {
    $set2.=" ,LAST_PACKET_ID=$last_paket_id";    
  }
          if (isset($last_IP))
  {
    $set2.=" ,IP='$last_IP'";    
  }
        if (isset($client_apteka_number) && ($client_apteka_number)<>0 && ($client_apteka_number)<>"")
  {
    $set2.=" ,APTEKA_NUMBER=$client_apteka_number";    
  }

  mysql_query("INSERT INTO fz_log SET $set2");
  $f=@fopen("./log2.txt", "w");
if($f) { @fwrite($f, $set2); fclose($f); }
}


if ($action=="packet_list") {

  $last_paket_id=(int)$last_paket_id;

  $r=mysql_query("SELECT val FROM flags WHERE var='limited'");
  $f=mysql_fetch_array($r);

  if ($f['val']=='-1') {

    $r=mysql_query("SELECT * FROM layers WHERE name='$layer_name'");
    $f=mysql_fetch_array($r);
    
    if ($f['flag_full']=='Y') {
      $r=mysql_query("SELECT filename FROM paket WHERE layer_name='$layer_name' AND ID>$last_paket_id ORDER BY ID");
    } else {
      $r=mysql_query("(SELECT filename FROM paket WHERE layer_name='$layer_name' AND ID>$last_paket_id AND is_final='Y' ORDER BY ID) UNION (SELECT filename FROM paket WHERE layer_name='$layer_name' AND ID>$last_paket_id AND is_final='' ORDER BY ID DESC LIMIT 1)");
    }
        echo mysql_error();
    while ($f=mysql_fetch_array($r)) echo 'http://layers.pharmbase.com.ua/updates/'.$f['filename']."\r\n";
  } 
    if ($f['val']<>'-1') {
    
    $num = (int)$f['val'];
    $r=mysql_query("SELECT * FROM layers WHERE name='$layer_name'");
    $f=mysql_fetch_array($r);
    
    if ($f['flag_full']=='Y') {
      $r=mysql_query("SELECT filename FROM paket WHERE layer_name='$layer_name' AND ID>$last_paket_id AND ID<$num ORDER BY ID");
    } else {
      $r=mysql_query("(SELECT filename FROM paket WHERE layer_name='$layer_name' AND ID>$last_paket_id AND ID<$num AND is_final='Y' ORDER BY ID) UNION (SELECT filename FROM paket WHERE layer_name='$layer_name' AND ID>$last_paket_id AND ID<$num AND is_final='' ORDER BY ID DESC LIMIT 1)");
    }

    echo mysql_error();
    while ($f=mysql_fetch_array($r)) echo 'http://layers.pharmbase.com.ua/updates/'.$f['filename']."\r\n";
  }

   if (isset($install_iid))
  { 
    $install_iid=ereg_replace('"\'','',$install_iid);
    $client_version=ereg_replace('"\'','',$client_version);
    $client_db_version=(int)$client_db_version;

    $r=mysql_query("SELECT ID FROM fz_clients WHERE uid='$install_iid'");
    //echo mysql_error();
    if (($f=mysql_fetch_array($r)) && $f['ID']) {
      $clientID=$f['ID'];
    } else {
      mysql_query("INSERT INTO fz_clients SET uid='$install_iid'");
      //echo mysql_error();
      $clientID=mysql_insert_id();
    }

    if (isset($install_client_name) && ($install_client_name=trim($install_client_name))) {
      if (!get_magic_quotes_gpc()) $install_client_name=addslashes($install_client_name);
      mysql_query("UPDATE fz_clients SET install_client_name='$install_client_name' WHERE ID=$clientID");
    }

    mysql_query("INSERT INTO logdata SET clientID=$clientID,client_version='$client_version',client_db_version=$client_db_version,last_packet_id=$last_paket_id,IP='$_SERVER[REMOTE_ADDR]',date_add=UNIX_TIMESTAMP()");
    //echo mysql_error();
  }
}

if ($action=="get_id") {
  
  $install_iid=ereg_replace('"\'','',$install_iid);

  $r=mysql_query("SELECT ID FROM fz_clients WHERE uid='$install_iid'");
  if (($f=mysql_fetch_array($r)) && $f['ID']) {
    echo $f['ID'];
  } else {
    /*header("$_SERVER[SERVER_PROTOCOL] 404 Not Found");
    header('Connection: close');
    exit();*/
    echo '0';
  }
}

if ($action=="request_dict_row") {

  $filename=eregi_replace('[^a-z0-9.-]','',$filename);

  if (!($filename=trim($filename)) || !($row_data=trim($row_data))) {
    echo 'ERROR Incorrect input data.';
    exit();
  }

  $mail = new PHPMailer();
  $mail->SetLanguage('ru', '');

  $mail->From='support@morion.ua';
  $mail->AddReplyTo("support@morion.ua");
  $mail->AddAddress("mds@morion.ua");
  $mail->CharSet='WIN-1251';
  $mail->IsHTML(false);
  $mail->Subject="mds add request";
  $mail->AltBody='';

  $mail->attachment=array();
  
  $tempfile=uniqid("/tmp/MAIL");
  $fl=fopen($tempfile,'w');
  fwrite($fl,$row_data);
  fclose($fl);
  $mail->AddAttachment($tempfile, $filename);

  if ($mail->Send()) {
    echo "OK";
  } else {
    echo "Message was not sent. Mailer Error: ".$mail->ErrorInfo.'<br>';
  }

  unlink($tempfile);

}

?>