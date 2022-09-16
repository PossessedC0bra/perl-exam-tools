package Text::Stopwords;

use v5.30.3;
use strict;
use warnings;
use experimental;

use Exporter 'import';
our @EXPORT_OK = qw(get_stopwords);

#####################################################################

sub get_stopwords() {
    return qw(
      i
      me
      my
      myself
      we
      our
      ours
      ourselves
      you
      you're
      you've
      you'll
      you'd
      your
      yours
      yourself
      yourselves
      he
      him
      his
      himself
      she
      she's
      her
      hers
      herself
      it
      it's
      its
      itself
      they
      them
      their
      theirs
      themselves
      what
      which
      who
      whom
      this
      that
      that'll
      these
      those
      am
      is
      are
      was
      were
      be
      been
      being
      have
      has
      had
      having
      do
      does
      did
      doing
      a
      an
      the
      and
      but
      if
      or
      because
      as
      until
      while
      of
      at
      by
      for
      with
      about
      against
      between
      into
      through
      during
      before
      after
      above
      below
      to
      from
      up
      down
      in
      out
      on
      off
      over
      under
      again
      further
      then
      once
      here
      there
      when
      where
      why
      how
      all
      any
      both
      each
      few
      more
      most
      other
      some
      such
      no
      nor
      not
      only
      own
      same
      so
      than
      too
      very
      s
      t
      can
      will
      just
      don
      don't
      should
      should've
      now
      d
      ll
      m
      o
      re
      ve
      y
      ain
      aren
      aren't
      couldn
      couldn't
      didn
      didn't
      doesn
      doesn't
      hadn
      hadn't
      hasn
      hasn't
      haven
      haven't
      isn
      isn't
      ma
      mightn
      mightn't
      mustn
      mustn't
      needn
      needn't
      shan
      shan't
      shouldn
      shouldn't
      wasn
      wasn't
      weren
      weren't
      won
      won't
      wouldn
      wouldn't
    );
}

#####################################################################

1;    # Magic boolean TRUE value required at end of a module

#####################################################################

=encoding utf8

=head1 NAME

Text::Stopwords - Common english stopword list


=head1 VERSION

This document describes Text::Stopwords version 1.0.0


=head1 SYNOPSIS

    use Text::Stopwords;

    get_stopwords();
    # returns a list of common english stopwords ('i', 'me', ...)


=head1 DESCRIPTION

This module provides an easy way to get a list of common english stopwords.
The list was curated by the an open source community and contributed
to the natural language toolkit (NLTK).


=head1 INTERFACE

=head2 get_stopwords()

Returns a list of common english stopwords as seen in the natural language toolkit (NLTK).


=head1 See also

L<https://www.nltk.org>
L<https://github.com/nltk/nltk_data/blob/gh-pages/packages/corpora/stopwords.zip>


=head1 AUTHOR

Yannick Koller  C<< <yannick.koller@students.fhnw.ch> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2022, Yannick Koller C<< <yannick.koller@students.fhnw.ch> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
ALL SUCH WARRANTIES ARE EXPLICITLY DISCLAIMED. THE ENTIRE RISK AS TO THE
QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE
PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR,
OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE LIABLE
FOR DAMAGES, INCLUDING ANY DIRECT, INDIRECT, GENERAL, SPECIAL, INCIDENTAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES, HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING OUT OF THE USE OR INABILITY TO USE THE
SOFTWARE (INCLUDING BUT NOT LIMITED TO PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES, LOSS OF DATA OR DATA BEING RENDERED INACCURATE, OR LOSSES
SUSTAINED BY YOU OR THIRD PARTIES, OR A FAILURE OF THE SOFTWARE TO
OPERATE WITH ANY OTHER SOFTWARE) EVEN IF SUCH HOLDER OR OTHER PARTY HAS
BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
