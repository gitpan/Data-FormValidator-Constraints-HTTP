package Data::FormValidator::Constraints::HTTP;

use strict;
use warnings;
use base qw( Exporter );

our $VERSION = '0.01';

our @EXPORT_OK = qw(
    http_method
    DELETE
    GET
    OPTIONS
    POST
    PUT
    TRACE
);

=head1 NAME

Data::FormValidator::Constraints::HTTP - Simple Data::FormValidator 
constraint methods for checking various HTTP methods.

=head1 SYNOPSIS

    
    use Data::FormValidator;
    use Data::FormValidator::Constraints::HTTP qw( POST );
    
    my %input = (
        method => $request->method,
        author => $request->parameter('author'),
        name   => $request->parameter('name'),
    );
    
    my %profile = (
        required           => [ qw( method author ) ],
        optional           => [ qw( name ) ],
        constraint_methods => {
            method         => POST,
        },
    );
    
    my $results = Data::FormValidator->check( \%input, \%profile );
    
    # If $request->method was not 'POST', then this form validation 
    # will not be successful.
    

=head1 DESCRIPTION

This module provides some simple, Data::FormValidator compatible 
constraint methods for validating HTTP request methods. For example, 
it may be desirable to consider a form invalid until the request method 
is POST.

=head1 INTEGRATION WITH THE CATALYST WEB FRAMEWORK

I have found this technique of making forms invalid unless the request 
method is POST to be rather useful within the Catalyst web framework, 
using the FormValidator and FillInForm plugins.

The FillInForm plugin will automatically fill in an HTML form with the 
values located in $c->request->parameters *AS LONG AS THE CURRENT FORM 
IS INVALID*. We can use this behaviour to make our lives simpler. By 
placing the HTTP method constraint method in our validation profile, 
we can be guaranteed that FillInForm will engage if the method is not 
POST (it may still engage even if the method *IS* POST, depending on 
the form validation profile and the client's provided input).
    
    
    package My::App;
    
    use Catalyst qw( Static::Simple FillInForm FormValidator );
    
    1;
    
    
    
    ...
    
    
    
    package My::App::Controller::Root;
    
    use base qw( Catalyst::Controller );
    
    sub auto : Private {
        my ($self, $c) = @_;
        
        # The HTTP request method must be placed into the request 
        # parameters in order for the FormValidator plugin to check it.
        # This can easily be done in the root controller's "auto" 
        # action to avoid this in the various controllers.
        # Just another tip to make the code cleaner. :)
        $c->request->parameter( method => $c->request->method );
        
        1;
    }
    
    1;
    
    
    
    ...
    
    
    
    package My::App::Controller::Foo;
    
    use Data::FormValidator::Constraints::HTTP qw( POST );
    
    sub update : Local {
        my ($self, $c, $foo) = @_;
        $foo = $c->model('Schema::Foo')->find( $foo );
        
        $c->form(
            required           => [ qw( method name author ) ],
            constraint_methods => {
                method         => POST,
                name           => FV_min_length( 6 ),
                # ... yadda, yadda, yadda
            },
        );
        
        if ($c->form->success) {
            # you can be sure this will only be reached if the request 
            # method is POST and the rest of the request parameters 
            # have successfully passed the rest of your form validation 
            # profile.
            
            $foo->update_from_form( $c->form );
        }
        else {
            # By setting the parameters in this manner, FillInForm will 
            # automatically fill in the HTML form using the current 
            # object values, being overridden by any request parameters 
            # already specified. Meaning, if $foo get a field called 
            # 'title' and its value had already been set, FillInForm 
            # will place that value into the HTML form being presented 
            # to the client. However, if the request parameters include 
            # a value for 'title', *THAT* value gets placed in the 
            # HTML form.
            
            $c->request->parameters({
                $foo->get_columns,
                %{ $c->request->parameters },
            });
        }
    }
    
    1;
    

=head1 METHODS

=head2 http_method ( $method )

Returns a constraint method to determine whether or not a method is 
equal to the provided variable.

=head2 DELETE ( )

=head2 GET ( )

=head2 OPTIONS ( )

=head2 POST ( )

=head2 PUT ( )

=head2 TRACE ( )

Returns a constraint method to determine whether or not a method is 
equal to the name of the rule (i.e. - GET, POST, PUT, etc...).

=cut

sub http_method {
    my $method = shift;
    
    return sub {
        my $dfv = shift;
        
        $dfv->name_this('method');
        
        my $value = $dfv->get_current_constraint_value;
        
        if ($value and lc $value eq lc $method) {
            return 1;
        }
        else {
            return 0;
        }
    };
}

sub DELETE  { http_method('DELETE')  }
sub GET     { http_method('GET')     }
sub OPTIONS { http_method('OPTIONS') }
sub POST    { http_method('POST')    }
sub PUT     { http_method('PUT')     }
sub TRACE   { http_method('TRACE')   }

=head1 SEE ALSO

=over 4

=item * Data::FormValidator

=item * Data::FormValidator::Constraints

=item * Catalyst

=back

=head1 AUTHOR

Adam Paynter E<lt>adapay@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2006 by Adam Paynter

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

1;