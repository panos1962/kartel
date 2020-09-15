<?php
if (!class_exists("Globals"))
require_once "../lib/standard.php";

Globals::www_require("lib/selida.php");

Selida::head();
Selida::stylesheet("copyright/selida");
Selida::javascript("copyright/selida");
Selida::body();
Selida::toolbar();
Selida::fyi_pano();
Selida::ofelimo_open();
?>
<div class="kimeno">
<p>
<div class="titlos">
Copyright statement
</div>
</p>

<p>
Η εφαρμογή <em>kartel</em> αναπτύχθηκε τον Απρίλο του 2019 από προγραμματιστές
και τεχνικούς του Τμήματος Μηχανογραφικής Υποστήριξης του Δήμου Θεσσαλονίκης
με σκοπό τη διαχείριση και την επεξεργασία των χρονικών δεδομένων προσέλευσης
και αποχώρησης των υπαλλήλων.
Ο κώδικας καλύπτεται από copyleft license και τα οποιαδήποτε δικαιώματα
ανήκουν στο Δήμο Θεσσαλονίκης.
</p>
</div>
<?php
Selida::ofelimo_close();
Selida::fyi_kato();
Selida::ribbon();
Selida::telos();
?>
