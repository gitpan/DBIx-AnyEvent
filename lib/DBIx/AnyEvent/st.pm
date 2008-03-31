package # Hide from pause
  DBIx::AnyEvent::st;

use DBI;

use base qw/DBI::st/;

use strict;
use warnings;

sub execute {
  my ($self,@bind_values) = @_;

  my $guard = $self->{Database}->{private_DBIx_AnyEvent_mutex}->guard;

  $self->SUPER::execute (@bind_values);

  return $self->{Database}->_coro_wait_result;
}

1;

