# frozen_string_literal: true

module Legacy
  class Infoscience < Legacy::BaseCv
    self.table_name = 'boxes'
    self.primary_key = 'sciper'
    belongs_to :cv, class_name: 'Cv', foreign_key: 'sciper', inverse_of: false

    URL_RE = %r{(http|https)://infoscience-exports\.epfl\.ch/\d+/(\?ln=(fr|en))?}

    scope  :visible, -> { where(box_show: '1') }

    default_scope do
      where(position: 'P', sys: 'I')
    end

    def url
      URL_RE.match?(src) ? src : nil
    end

    def html_content
      return nil if url.nil?

      @html_content ||= begin
        c = InfoscienceGetter.call(url)
        c = c.to_s.force_encoding('UTF-8') unless c.nil? || (c.encoding == 'UTF-8')
        c
      end
    end

    # content of the box is just the infoscience url and must validate the following regex
    # return 1 if $src =~ m#^(http|https)://infoscience\-exports\.epfl\.ch/\d+/(\?ln=(fr|en))?#;
  end
end

# if ($box->{sys} eq 'I' && $box->{src} =~ m#$URLinfoscience#i) {
#   if ($USE_INFOCACHE) {
#     # - USE CACHE
#     my $ts = $box->{ts};
#     $ts =~ s/\-/:/g;
#     $ts =~ s/\s/:/g;
#     my ($yr,$mon,$day,$hr,$min,$sec) = split (/:/, $ts);
#     if (((time() - timelocal ($sec,$min,$hr,$day,($mon-1),$yr)) > $CACHE_LIFE) || ! $boxcontent ) {
#       # - CACHE OUTDATED
#       my $crtcontent = getInfoscienceData($self, $box);
#       $boxcontent    = $crtcontent
#                      ? $crtcontent
#                      : $boxcontent;
#     }
#   } else {
#     # - USE LIVE DATA
#     my $crtcontent = getInfoscienceData($self, $box);
#     $boxcontent    = $crtcontent
#                    ? $crtcontent
#                    : $boxcontent;
#   }
# }
#
# sub getInfoscienceData {
#   my ($self, $box) = @_;
#   return '' unless $box;
#   return '' unless chkInfoSrc($self, $box->{src});
#   my $crtcontent = getURL($self, $box->{src});
#
#   if ($crtcontent) {
#     utf8::decode($crtcontent) unless utf8::is_utf8 ($crtcontent);
#     if ($UPDATE_INFOCACHE && length($crtcontent) < $MYSQL_MAX_ALLOWED_PACKET) {
#       # - update cache si contenu OK
#       my $dbh  = $self->{dbh};
#       my $sql = qq{update boxes set content = ?, ts=now() where id = ?};
#       my $sth = $dbh->prepare( $sql ) or die "** ERR people prepare :$sql: $DBI::errstr\n";
#       $sth->execute (($crtcontent, $box->{id})) or die "** ERR execute : $DBI::errstr\n";
#     }
#     return $crtcontent;
#   } else {
#     #warn "--> infoscience bad response \n";
#     return '';
#   }
# }
