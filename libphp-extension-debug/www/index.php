
<?php
 if (!extension_loaded('test')) {
    echo 'skip';
    dl('test.so'); 
}
 $ret = mysprintf("%s", "word");
var_dump($ret); 

 phpinfo();

?>