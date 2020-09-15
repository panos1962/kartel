<?php
if (!class_exists("Globals"))
require_once "../lib/standard.php";

Globals::www_require("lib/selida.php");

Selida::head('kartel [beta]');
Selida::stylesheet("beta/selida");
Selida::javascript("beta/selida");
Selida::body();
Selida::toolbar();
Selida::fyi_pano();
Selida::ofelimo_open();
?>
<div class="kimeno">
<p>
<div class="titlos">
This is beta version!
</div>
</p>

<p>
Η εφαρμογή <em>kartel</em> βρίσκεται σε φάση beta, πράγμα που σημαίνει
ότι η εφαρμογή λειτουργεί πιλοτικά με σκοπό, κατά πρώτον,
τη διόρθωση τυχόν σφαλμάτων και τη θεραπεία τυχόν προβλημάτων
και δυσλειτουργιών και, κατά δεύτερον, τη βελτίωση των προγραμμάτων
και την ενσωμάτωση νέων λειτουργιών που ενδεχομένως θα προκύψουν
μέσα από την καθημερινή χρήση της εφαρμογής.
</p>
</div>
<?php
Selida::ofelimo_close();
Selida::fyi_kato();
Selida::ribbon();
Selida::telos();
?>
