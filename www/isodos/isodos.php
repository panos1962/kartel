<?php
require_once "../lib/standard.php";

Globals::header_data();

if (Globals::no_session(PUBKEY))
Globals::klise_fige(0);

// Είμαστε σε κανονική λειτουργία του παρόντος script, οπότε πρέπει
// να έχουν περαστεί τα στοιχεία εισόδου και το κλειδί της μελλούμενης
// συνεδρίας.

$ipalilos = Globals::perastike_must("ipalilos");
$password = Globals::perastike_must("password");
$pubkey = Globals::session_get(PUBKEY);

// Συνδεόμαστε με την database και προχωρούμε σε έλεγχο ορθότητας των
// στοιχείων εισόδου.

$prosvasi = (new Prosvasi())->
pubkey_set($pubkey)->
ipalilos_set($ipalilos)->
password_set($password)->
prosvasi_fetch();

// Αν δεν εντοπίστηκε ο υπάλληλος με τα δοθέντα στοιχεία εισόδου, τότε
// έχουμε απόπειρα εισβολής.

if ($prosvasi->ipalilos != $ipalilos)
Globals::klise_fige(0);

// Δόθηκαν ορθά στοιχεία εισόδου, επομένως δημιουργούμε διαπιστευτήρια
// στο session cookie.

Globals::session_clear("forgot");
Globals::session_set(IPALILOS, $ipalilos);
Globals::session_set(PUBKEY, $pubkey);
Globals::session_set(AUTHDEPT, $prosvasi->ipiresia);
Globals::session_set(AUTHLEVEL, $prosvasi->level);
Globals::klise_fige(0, AJXRSPOK);
?>
