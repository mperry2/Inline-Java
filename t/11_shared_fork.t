use strict ;
use Test ;


BEGIN {
	if ($ENV{PERL_INLINE_JAVA_JNI}){
		plan(tests => 0) ;
		exit ;
	}
}


use Inline Config => 
           DIRECTORY => './_Inline_test' ;

use Inline (
	Java => 'DATA',
	SHARED_JVM => 1,
) ;



if (! Inline::Java::Portable::portable('GOT_FORK')){
	plan(tests => 0) ;
	exit ;
}


my $nb = 10 ;
plan(tests => $nb + 1) ;


$t13::i = 0 ;

my $sum = (($nb) * ($nb + 1)) / 2 ;
for (my $i = 0 ; $i < $nb ; $i++){
	if (! fork()){
		do_child($i) ;
	}
}


# Wait for kids to finish
for (my $i = 0 ; $i < $nb ; $i++){
	sleep(1) ;
	ok(1) ;
}

ok($t13::i, $sum) ;


sub do_child {
	my $i = shift ;

	Inline::Java::reconnect_JVM() ;

	my $t = new t13() ;
	for (my $j = 0 ; $j <= $i ; $j++){
		$t->incr_i() ;
	}
	exit ;
}


__DATA__

__Java__


class t13 {
	static public int i = 0 ;

	public t13(){
	}

	public void incr_i(){
		i++ ;
	}
}
