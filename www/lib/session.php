<?php

ini_set("session.gc_maxlifetime", "604800");
session_set_cookie_params(604800);
session_start();
header('Content-type: text/plain; charset=utf-8');

foreach ($_POST as $tag => $val)
$_SESSION[rawurldecode($tag)] = rawurldecode($val);
?>
