package MyDbi;
use warnings;
use strict;
use Moose;
use DBI;
use DBIx::Connector;
use DBD::Pg qw(:pg_types);
use Data::Page;

my $page = Data::Page->new();
has 'Database_name'  => (is => 'rw', isa => 'Str', required => 1);
has 'User_name'      => (is => 'rw', isa => 'Str', required => 1);
has 'Password'       => (is => 'rw', isa => 'Str', required => 1);
has 'conn' => ( is   => 'rw',lazy => 1, builder => 'db_conn');


sub db_conn {

   my ($self) = @_;
   my $driver  = "Pg"; 
   my $database = $self->Database_name;
   my $dsn = "DBI:$driver:dbname = $database;host = localhost;port = 5432";
   my $userid = $self->User_name;
   my $password = $self->Password;
   my $dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 }) 
      or die $DBI::errstr;

#    print $dsn;
    
   return $dbh;
}

sub insert {

   my $self   = shift;
   my %params = @_;

   my %columns = %{$params{Columns}};

   my $stmt = "INSERT INTO ".$params{table}." (";

   my $insert;

   my @values;

   my $Qval;

   for my $var(keys %columns){

       push ( @values, $columns{$var} );

      if(!$insert){

        $insert = $var;

        $Qval = "?";
        
      }

      else
      {

        $insert .= ",".$var;

        $Qval .= ", ?";

      }

   }

 
   $stmt .= $insert.") VALUES (".$Qval.")";

   my $dbh = $self->conn;

   my $sth = $dbh->prepare_cached($stmt) or die $DBI::errstr;

   my $rv1 = $sth->execute(@values);

   if( $rv1 < 0 ) {
      print $DBI::errstr;
   }

}

sub select {

    my $self = shift;
    my %params = @_;

    my %columns = %{$params{select}};

    my %where;

    my $select_columns;

    my $where_clause;

    my @values;

    foreach my $col( keys %columns ){

        if(!$select_columns){
         $select_columns = $col;
        }
        else{
         $select_columns .= ", $col";
        }

    }

    my $stmt = "SELECT ".$select_columns." FROM ".$params{table};

    if($params{where}){

        my %where = %{$params{where}};

        foreach my $col( keys %where ){

            push ( @values, $where{$col} );

            if(!$where_clause){
                $where_clause = " WHERE $col = ?";
            }
            else{
                $where_clause .= " AND $col = ?";
            }

        }

        $stmt .= $where_clause;

    }

    # print $stmt;    

    my $dbh = $self->conn;

    # my $sth = $dbh->prepare( q{SELECT * FROM employee LIMIT ?, ?});
    # my $rv  = $sth->execute($page->skipped, $page->entries_per_page);

    my $sth = $dbh->prepare_cached($stmt);

    my $rv = $sth->execute(@values) or die $DBI::errstr;

    if($rv < 0) {
      print $DBI::errstr;
    }

    my @data;
   
    while(my $row = $sth->fetchrow_hashref()) {
        push (@data, $row);
    }
    
    return @data;

}

sub delete {

    my $self   = shift;
    my %params = @_;

    my %where;

    my $where_clause;

    my $stmt = "DELETE FROM ".$params{table};

    my @values;

    if($params{where}){

        my %where = %{$params{where}};

        foreach my $col( keys %where ){

            push ( @values, $where{$col});

            if(!$where_clause){
                $where_clause = " WHERE $col= ?";
            }
            else{
                $where_clause .= " AND $col= ?";
            }

        }

        $stmt .= $where_clause;

    }

    # print $stmt;    

    my $dbh = $self->conn;

    my $sth = $dbh->prepare_cached($stmt);

    my $rv = $sth->execute(@values) or die $DBI::errstr;

    if($sth){

        print "Employee were deleted";

    }

    if($rv < 0) {
      print $DBI::errstr;
    }

}

sub update {

   my $self   = shift;
   my %params = @_;

   my %set = %{$params{set}};

   my %where = %{$params{where}};

   my $set_form;

   my $stmt = "UPDATE ".$params{table}." SET ";

   my @values;

   for my $var(keys %set){

       push(@values, $set{$var});

      if(!$set_form){

        $set_form .= $var." = ? ";
        
      }

      else
      {

      $set_form .= ",".$var." = ?";

      }

   }

   $stmt .= $set_form." WHERE ";
   my $where_clause;
   for my $var(keys %where){

        push(@values, $where{$var});

      if(!$where_clause){
         $where_clause = "$var= ?";
      }
      else{
         $where_clause .= "AND $var= ?";
      }

   }

   $stmt .= $where_clause;
   # UPDATE users set firstname = 'Rohini' where ID=1;

#    print $stmt;

   my $dbh = $self->conn;

   my $sth = $dbh->prepare_cached($stmt) or die $DBI::errstr;

   my $rv1 = $sth->execute(@values);

   if( $rv1 < 0 ) {
      print $DBI::errstr;
   }
   else{
       "Table ".$params{table}." is updated."
   }

}

sub ViewAll {

    my $self = shift;
    my %params = @_;

    my %columns = %{$params{select}};

    my %where;

    my $select_columns;

    my $where_clause;

    my @values;

    foreach my $col( keys %columns ){

        if(!$select_columns){
         $select_columns = $col;
        }
        else{
         $select_columns .= ", $col";
        }

    }

    my $stmt = "SELECT ".$select_columns." FROM ".$params{table};

    if($params{where}){

        my %where = %{$params{where}};

        foreach my $col( keys %where ){

            push ( @values, $where{$col} );

            if(!$where_clause){
                $where_clause = " WHERE $col = ?";
            }
            else{
                $where_clause .= " AND $col = ?";
            }

        }

        $stmt .= $where_clause;

    }

    # print $stmt;    

    my $dbh = $self->conn;
    my $sth = $dbh->prepare_cached($stmt);

    my $rv = $sth->execute(@values) or die $DBI::errstr;

    if($rv < 0) {
      print $DBI::errstr;
    }

    my @data;
   
    while(my $row = $sth->fetchrow_hashref()) {
        push (@data, $row);
        
    }

    # print "hi";
    
    return @data;

}

1;