package # Hide from pause
  DBIx::AnyEvent::db;

use AnyEvent;
use AnyEvent::Semaphore;
use Carp;
use DBI;
use DBD::Pg;

use base qw/DBI::db/;

use strict;
use warnings;

sub do {
  my ($self,$statement,$attr,@bind_values) = @_;

  $attr ||= {};

  $attr->{pg_async} = DBD::Pg::PG_ASYNC;

  my $guard = $self->{private_DBIx_AnyEvent_mutex}->guard;

  $self->SUPER::do ($statement,$attr,@bind_values);

  return $self->_coro_wait_result;
}

sub prepare {
  my ($self,$statement,$attr) = @_;

  $attr ||= {};

  $attr->{pg_async} = DBD::Pg::PG_ASYNC;

  my $guard = $self->{private_DBIx_AnyEvent_mutex}->guard;

  my $sth = $self->SUPER::prepare ($statement,$attr);

  return $sth;
}

sub connected {
  my ($self) = shift;

  Carp::confess "DBIx::AnyEvent only supports DBD::Pg currently"
    unless $_[0] =~ /^dbi:Pg:/i;

  $self->{private_DBIx_AnyEvent_mutex} = AnyEvent::Semaphore->new;

  open my $fh,">&=",$self->{pg_socket};

  $self->{private_DBIx_AnyEvent_fh} = $fh;

  return $self->SUPER::connected (@_);
}

sub _coro_wait_result {
  my ($self) = @_;

  my $c = AnyEvent->condvar;

  my $w = AnyEvent->io (fh => $self->{private_DBIx_AnyEvent_fh},poll => 'r',cb => sub {
      $c->broadcast if $self->pg_ready;
    });

  $c->wait;

  return $self->pg_result;
}

1;

