$MasterPath = "/home/virtual/site23/fst/home/bluewand/data/classic"

sub chopper{
	foreach $k(@_){
		chomp($k);
	}
}

sub Space {
  local($_) = @_;
  1 while s/^(-?\d+)(\d{3})/$1 $2/; 
  return $_; 
}