use Employee;
use warnings;
use strict;

my $object = Employee->new();

my $option = $object->options();

sub actions{

$option= shift @_;

if($option == 1){

    print "Add the number of employee.\n";

    my $Eml_num = <STDIN>;  

    # print  $Eml_num;

    # my %empl_IDWise ;

    my @emp_object;

    for( my $i = 1; $i <= $Eml_num; $i++)   {

        my $emp1;

        print "Enter the name of Employee.\n";

        my $name = <STDIN>;

        print "Enter the title of Employee.\n";

        my $title = <STDIN>;

        print "Enter the address of Employee.\n";

        my $address = <STDIN>;

        print "Enter the Salory of Employee.\n";

        my $salary = <STDIN>;

        
        # $eml_details{$ID} = \%empl_IDWise;

        # print $eml_details{$empl_IDWise{'ID'}}->{ID};

        $emp1 = Employee->new(

            name => $name,
            address => $address,
            salary => $salary,
            title => $title,

        );

        push (@emp_object, $emp1);

       

    }  


    foreach my $var(@emp_object){
        $var->add_employee();

        if($emp_object[@emp_object - 1] == $var){

            print "\nEmployees were added.\n";

            $option = $object->options();

             actions($option);

        }
    }

}

if( $option == 2){

    $object->view_single_eml();

    $option = $object->options();

    actions($option);

}

if( $option == 3){

    $object->delete_emp();

    $option = $object->options();

    actions($option);

}

if($option == 4){

    $object->edit_empl();

    $option = $object->options();

    actions($option);

}

if($option == 5){

    $object->view_all_emp();

    $option = $object->options();

    actions($option);

}

}

actions($option);