package Employee;
use Moose;
use Data::Dumper qw( Dumper );
use List::Util qw(max);
use MyDbi;
use Data::Paginator;
use Data::Page;
use warnings;
use strict;
use Data::Dumper;

has 'name' => (is => 'rw', isa => 'Str',);
has 'address' => (is => 'rw', isa => 'Str', );
has 'salary' => (is => 'rw', isa => 'Str', );
has 'title' => (is => 'rw', isa => 'Str', );
# has 'all_empl' => (is => 'rw',default => sub { {} },);

has 'delete_ans' => (is => 'rw', isa => 'Str');
has 'edit_info' => (is => 'rw', isa => 'Str', );

my $pager = Data::Paginator->new(
    current_page => 1,
    entries_per_page => 10,
    total_entries => 100,
);

my $page = Data::Page->new();

my $app = Employee->new();

my $DbObject = MyDbi->new(
    Database_name => 'rohini',
    User_name     => 'postgres',
    Password      => '12345',
);

sub options {

print "\nCHOOSE ANY ONE OPTION.\n\n
1.add a new employee\n
2.view employee details\n
3.delete the employee\n
4.Edit the employee detail\n
5.View all the employee details\n\n";     

my $option = <STDIN>;

return $option;

}

sub add_employee {

    my $self= shift @_;

    $DbObject->insert( table => 'employee', Columns => {name => $self->name, title => $self->title, address => $self->address, salary => $self->salary });    
    
}

# before 'add_employee' => sub { print "about to call foo\n"; };
# after 'add_employee'  => sub { print "just called foo\n"; };


sub view_single_eml {

    my $self= shift @_;

    my @Ids = $DbObject->select(table => 'Employee', select => {id => 'id'});

    if(@Ids){

        print "Choose the Id of employee.\n\n";       

        for my $value(@Ids){

            my %data = %{$value}; 

            for my $value(keys %data){

              print $value." = ".$data{$value}."\n";

            } 

        }

        my $view_id = <STDIN>;
        chomp $view_id;  

        my @single_emp = $DbObject->select(table => 'Employee', select => {id => 'id', name => 'name', title => 'title', address =>'address',salary => 'salary'}, where => {id => $view_id });

        for my $value1(@single_emp){

            my %data = %{$value1}; 

            for my $value1(keys %data){

              print $value1." = ".$data{$value1}."\n";

            } 

        }
        # print "\n\nEmployee ID ==> ".$view_id."\n";
    }   

    else{
        print "No data found\n\n";
    }

}

sub delete_emp {
    my $self= shift @_;

    my @Ids = $DbObject->select(table => 'Employee', select => {id => 'id'});

    if(@Ids){

        print "Choose the Id of employee to delete.\n\n";

        for my $value(@Ids){

            my %data = %{$value}; 

            for my $value(keys %data){

              print $value." = ".$data{$value}."\n";

            } 

        }

        my $Delete_ID = <>;
        chomp $Delete_ID;  

        if($Delete_ID){
            print "Are you sure, Do you want to delete this employee ?[Y/N]\n\n";


            my $delete_ans1 = <>;

            chomp $delete_ans1;

            $app->delete_ans($delete_ans1) ;

            # print $app->delete_ans;

            if($delete_ans1 eq 'Y'){

                my $delete = $DbObject->delete(table => 'Employee', where => { id  => $Delete_ID });
                
            }
        }

    } 

    else{
        print "No data found\n\n";
    }

}
# print $app->delete_ans;
# if($app->delete_ans && ($app->delete_ans eq 'N')){

#     after 'delete_emp'  => sub { print "Employee were deleted\n"; };

# }

sub edit_empl {
    my $self = shift @_;

    my @Ids = $DbObject->select(table => 'Employee', select => {id => 'id'});

    if(@Ids){

        print "Choose the Id of employee to update.\n\n";

        for my $value(@Ids){

            my %data = %{$value}; 

            for my $value(keys %data){

              print $value." = ".$data{$value}."\n";

            } 

        }

        my $Edit_ID = <>;
        chomp $Edit_ID;  

        if($Edit_ID){

            print "Which data do you want to update?\nname\ntitle\naddress\nSalory\n";

            my $edit_data = <>;

            chomp $edit_data;

            print "Enter the ".$edit_data." of Employee.\n";
            
            my $newData = <>;
            chomp $newData;

            $DbObject->update(table => 'Employee', set => { $edit_data => $newData}, where => {id => $Edit_ID});

        } 
        else
        {
            print "No data found\n\n";
        }   
    
    }

}

# if($app->edit_info){

#     after 'edit_empl'  => sub { print "Employee were updated\n"; };

# }

sub view_all_emp {

    my $self= shift @_;   
    
    my @all_emp = $DbObject->ViewAll(table => 'Employee', select => {id => 'id', name => 'name', title => 'title', address =>'address',salary => 'salary'});

    my $count = @all_emp;

    my $rounds = $count/3;

    my @pages = split('.', $rounds);

    

    my $i = 0;

    my $j = 2;

    my @slice = @all_emp[$i..$j];

        if(@all_emp){

        for my $value1(@slice){

            # print $value1->{values};

            my %data = %{$value1}; 

            for my $value1(keys %data){

              print $value1." = ".$data{$value1}."\n";

            } 

        }

        print "Enter N for next employee data OR P for previous data\n";

        my $event = <>;
        chomp $event;

        if($event eq 'N'){

            $i = $i + 3;

            $j = $j + 3;


        }

        if($event eq 'P'){

            $i = $i - 3;

            $j = $j - 3;


        }

        for(my $m = $i; $m > 0; $m++){

            @slice = @all_emp[$i..$j];

             my $count = @slice;

                    # print $count." count ".$all_emp[$i]." \n";

            if(!$all_emp[$i] || $i < 0){
                last;
            
            }
            else
            {
                for my $value1(@slice){                   

                if($value1){

                my %data = %{$value1}; 

                    for my $value1(keys %data){

                    print $value1." = ".$data{$value1}."\n";

                    } 

                }
                

            }
            }

            print "Enter N for next employee data OR P for previous data\n";

            my $event = <>;
            chomp $event;

            if($event eq 'N'){

                $i = $i + 3;

                $j = $j + 3;


            }

            elsif($event eq 'P'){

                $i = $i - 3;

                $j = $j - 3;


            }
            else{
                last;
            }

        }

        

        }

        else

        {
            print "No data found\n\n";
        }

}

__PACKAGE__->meta->make_immutable;

1;

